library(RColorBrewer)
library(dplyr)
library(sf)
library(rvest)

# From https://www.census.gov/data/tables/time-series/demo/popest/2020s-counties-total.html
counties_pop_url <- "https://www2.census.gov/programs-surveys/popest/tables/2020-2022/counties/totals/co-est2022-pop.xlsx"

# From https://github.com/tonmcg/US_County_Level_Election_Results_08-20/
counties_results_url <- "https://github.com/tonmcg/US_County_Level_Election_Results_08-20/raw/master/2020_US_County_Level_Presidential_Results.csv"

download_data <- function(url, out_dir = "./raw_data/") {
    out_file <- paste0(out_dir, basename(url))
    if (!file.exists(out_file)) {
        if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
        download.file(url, out_file)
    } else {
        message("File already exists: ", out_file)
    }
    return(out_file)
}

# Clean the data into county_name and state_name
counties_pop <- download_data(counties_pop_url) |>
    readxl::read_excel(skip = 2) |>
    transmute(
        area = gsub("^\\.", "", `Geographic Area`),
        pop = `April 1, 2020 Estimates Base`
    ) |>
    tidyr::separate_wider_delim(
        area,
        delim = ", ", names = c("county_name", "state_name"),
        too_few = "debug", too_many = "debug"
    ) |>
    filter(area_pieces == 2) |>
    select(-c(area_ok, area_pieces, area_remainder))

counties_results <- download_data(counties_results_url) |>
    read.csv() |>
    filter(!state_name %in% "Alaska")

# Connecticut is missing from counties_pop - counties are defined differently
anti_join(counties_results, counties_pop, by = c("county_name", "state_name")) |>
    filter(state_name == "Connecticut") |>
    pull(county_name)

# Get Connecticut from Wikipedia (use WayBack machine link which should persist even if Wikipedia changes)
connecticut_url <- "https://web.archive.org/web/20230924220256/https://en.wikipedia.org/wiki/List_of_counties_in_Connecticut"
page <- connecticut_url |>
    read_html()
connecticut_pop <- page |>
    html_elements(".wikitable") |>
    html_table() |>
    purrr::pluck(1) |>
    transmute(
        county_name = County,
        state_name = "Connecticut",
        area = paste(county_name, state_name, sep = ", "),
        pop = as.numeric(gsub(",", "", `Population[14]`))
    )
counties_pop <- bind_rows(counties_pop, connecticut_pop)

# We are OK now

us <- inner_join(
    counties_results, counties_pop,
    by = c("county_name", "state_name")
)

write.csv(us, "./csv/us_counties_results_with_pop.csv")

# OK so the next step is to bring this back in and attach it to a shape file
# then make the various maps - normal and contiguous/non-contiguous etc.

# * Shape file
load_shp <- function(in_file = NULL, zip_url = NULL) {
    if (sum(is.null(in_file), is.null(zip_url)) != 1) {
        stop("Please provide exactly one of `in_file` or `zip_url`")
    }

    if (!is.null(zip_url)) {
        in_file <- download_data(zip_url)
    }

    # This is a nested zip file
    county_zip <- grep("county.+\\.zip$", unzip(in_file, list = TRUE)$Name, value = TRUE)
    county_full_path <- paste0(dirname(in_file), "/", county_zip)
    if (!file.exists(county_full_path)) {
        message("Unzipping second layer of zip files...")
        unzip(in_file, exdir = dirname(in_file))
    } else {
        message("Shapefile already unzipped")
    }

    shp_file <- grep("\\.shp$", unzip(county_full_path, list = TRUE)$Name, value = TRUE)
    shp_full_path <- paste0(dirname(in_file), "/", shp_file)
    if (!file.exists(shp_full_path)) {
        message("Unzipping shapefile...")
        unzip(county_full_path, exdir = dirname(county_full_path))
    } else {
        message("Shapefile already unzipped")
    }
    st_read(shp_full_path, quiet = TRUE)
}

counties_shp_zip_url <- "https://www2.census.gov/geo/tiger/GENZ2020/shp/cb_2020_us_all_20m.zip"
counties_shp <- load_shp(zip_url = counties_shp_zip_url)

counties_shp <- counties_shp |>
    mutate(county_fips = as.integer(GEOID))

# Only Puerto Rico won't match if we join - that's fine, we don't want it
# for the map
anti_join(counties_shp, us, by = "county_fips")

election_shp <- inner_join(counties_shp, us, by = "county_fips") |>
    mutate(winner = ifelse(diff < 0, "Democrat", "Republican")) |>
    filter(state_name != "Hawaii")

saveRDS(election_shp, "./csv/us_election_shp_counties.rds")

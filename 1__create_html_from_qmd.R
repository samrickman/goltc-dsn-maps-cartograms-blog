# This function was to create the renv() the first time
# it will never be run if the repo is cloned
create_renv <- function() {
    if (dir.exists("renv")) {
        message("renv already created")
        return(invisible(NULL))
    }
    message("Creating renv...")

    # Create a .R file from the qmd file(s) so renv can capture
    # all dependencies
    qmd_files <- dir(pattern = "\\.qmd$")
    r_files <- lapply(qmd_files, knitr::purl)

    # Initialise renv()
    renv::init()
    # Now we can delete the .R file(s) we just created
    lapply(r_files, unlink)
    # You have to restart R after creating an renv
    quit()
}

create_directories <- function(dirs = c("./csv", "./img", "./raw_data")) {
    lapply(dirs, \(x) if (!dir.exists(x)) dir.create(x))
    invisible(NULL)
}

create_renv()
create_directories()

# Clean US election data (takes about 10 seconds to run)
message("Cleaning US election data...")
source("./2a__us_election_counties_clean_data.R")
message("Generating US cartogram...")
# Create Dorling cartogram (takes around 15 minutes to run!)
source("./2b__create_us_election_dorling_cartogram.R")

# Then do the render
system("quarto render ./GoLTC-maps-cartograms-blog-post.html")

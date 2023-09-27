# To manage R dependencies
if (!require("renv")) install.packages("renv")

# This function was to create the renv() the first time
# it will never be run if the repo is cloned
create_renv <- function() {
    if (dir.exists("renv")) {
        message("renv already created")
        return(invisible())
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

create_directory_structure <- function(dirs = c("./csv", "./img", "./raw_data")) {
    lapply(dirs, \(x) if (!dir.exists(x)) dir.create(x))
    invisible(NULL)
}

restore_renv <- function() {
    # If you git clone you don't get the actual libraries
    # just the lockfile, so they need to be downloaded the first time
    if (dir.exists("./renv/library/")) {
        message("renv libraries already created.")
        return(invisible())
    }
    message("renv libraries not found. Restoring...")
    renv::restore()
}

create_html <- function() {
    # Clean US election data (takes about 10 seconds to run)
    message("Cleaning US election data...")

    source("./2a__us_election_counties_clean_data.R")
    message("Generating US cartogram...")
    # Create Dorling cartogram (takes around 15 minutes to run!)
    source("./2b__create_us_election_dorling_cartogram.R")

    # Do the render from here - then no need to create a separate
    # batch script for different OSes
    system("quarto render ./GoLTC-maps-cartograms-blog-post.qmd")
}


create_renv()
create_directory_structure()
restore_renv()
create_html()

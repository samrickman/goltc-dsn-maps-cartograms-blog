library(sf)
library(ggplot2)
library(tmap)
library(cartogram)

us <- readRDS("./csv/us_election_shp_counties.rds")

us_min  <- us  |>
    st_simplify(
        preserveTopology = TRUE,
        dTolerance = 1000
    )

# * Dorling cartogram
cart_dorling <- st_transform(us, "EPSG:3857") |>
    cartogram_dorling(weight = "pop", k = 1, m_weight = 0.4)

# This ends up being 13mb as json in the html file
# We can make it about 2mb by simplifying polygons
cart_dorling_min  <- cart_dorling  |>
    st_simplify(
    preserveTopology = TRUE,
    dTolerance = 1000
)

saveRDS(cart_dorling, "./csv/us_cart_dorling_k1.rds")
saveRDS(cart_dorling_min, "./csv/us_cart_dorling_k1_min.rds")

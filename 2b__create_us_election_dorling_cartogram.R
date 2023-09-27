library(sf)
library(ggplot2)
library(tmap)
library(cartogram)

us <- readRDS("./csv/us_election_shp_counties.rds")

# # that's it basically
# us_map <- tm_shape(us) +
#     tm_fill(
#         col = "winner",
#         palette = c("Democrat" = "#0015BC", "Republican" = "#e81b23"),
#         legend.show = FALSE
#     ) + tm_layout(
#         main.title = "Map and cartogram of US 2020 election results",
#         main.title.position = "center"
#     )


# * Dorling cartogram
cart_dorling <- st_transform(us, "EPSG:3857") |>
    cartogram_dorling(weight = "pop", k = 1, m_weight = 0.4)

saveRDS(cart_dorling, "./csv/us_cart_dorling_k1.rds")

# Creating interactive maps and cartograms with R and Javascript

This is the repo for a blog post which is part of the _Communicating the findings of long-term care research_ series for the [Data Science Interest Group](https://goltc.org/interest-group/data-science/) of the [Global Observatory of Long Term Care](https://goltc.org/).

## Reproducibility

This blog post is created using public data and can reproduced. You will need [Quarto](https://quarto.org/), R and all the R packages contained in the (`renv.lock`)[./renv.lock] file.

`1.4.268`

1. `GoLTC-maps-cartograms-blog-post.qmd`. This is the [Quarto](https://quarto.org/) file used to generated the blog post. If you clone this repo, you should be able to render this into the actual blog post.
2. `GoLTC--maps-cartograms-blog-post.html`. This is the actual html file. To view this file as it appears on the web, move this file and the subfolder `/GoLTC--maps-cartograms-blog-post` to a public or local web server (e.g. Node [live server](https://www.npmjs.com/package/live-server) or Python [SimpleHttpServer](https://www.digitalocean.com/community/tutorials/python-simplehttpserver-http-server)).
3. The code to recreate the maps. This is generally contained within the Quarto file with the following exceptions:
   - The US election map and cartogram at the start of the post. These can be created by cloning this repo and running `1_create_html_from_qmd.R`.
   - Some javascript for the hex map, which is contained in `tooltip.js`.

The R package versions required to execute this script are stored within the `renv.lock` file. To reproduce this blog post from scratch you will need to `git clone` this repo and run [`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html).

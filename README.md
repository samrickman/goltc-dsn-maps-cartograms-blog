# Creating interactive maps and cartograms with R and Javascript

This is the repo for a blog post which is part of the _Communicating the findings of long-term care research_ series for the [Data Science Interest Group](https://goltc.org/interest-group/data-science/) of the [Global Observatory of Long Term Care](https://goltc.org/).

## Reproducibility

This blog post is created using public data and can reproduced. You will need [Quarto](https://quarto.org/), R and the [`renv`](https://rstudio.github.io/renv/articles/renv.html) package. This will ensure you have the required version of the R packages contained in the [`renv.lock`](./renv.lock) file.

To reproduce the blog post from the original data, `git clone` this repo and run the R file [./1\_\_create_html_from_qmd.R](./1__create_html_from_qmd.R). This will:

1. Ensure that you have `renv` and the required version of the R packages installed.
2. Recreate the US election map and cartogram at the start of the blog post. These are the only maps which are not created within the html file, as generating a population-weighted Dorling cartogram of all US counties takes about 15 minutes.
3. Generate the html file from `GoLTC-maps-cartograms-blog-post.qmd`, using the versions of the R packages set out in `renv.lock`.

The output will be:

1. `GoLTC--maps-cartograms-blog-post.html`. This is the actual html file.
2. `./GoLTC-maps-cartograms-blog-post_files/`. The folder

To view the file as it appears on the web, move the html file and the subfolder to a public or local web server (e.g. Node [live server](https://www.npmjs.com/package/live-server) or Python [SimpleHttpServer](https://www.digitalocean.com/community/tutorials/python-simplehttpserver-http-server)). Your web server should have the following file structure:

```
root
├── GoLTC--maps-cartograms-blog-post.html
└── GoLTC-maps-cartograms-blog-post_files/
    ├── Leaflet.Sync-0.0.5/
    ├── Proj4Leaflet-1.0.1/
    ├── bootstrap/
    ├── clipboard/
    ├── crosstalk-1.2.0/
    ├── d3-3.5.5/
    ├── d3-hexjson-3.5.5/
    ├── datatables-binding-0.27/
    ├── datatables-css-0.0.0/
    ├── dt-core-1.12.1/
    ├── echarts-gl-1.1.2/
    ├── echarts4r-4.8.0/
    ├── echarts4r-binding-0.4.4/
    ├── hexjsonwidget-binding-0.0.1/
    ├── highchart-binding-0.9.4/
    ├── highcharts-9.3.1/
    ├── htmlwidgets-1.6.2/
    ├── jquery-3.6.0/
    ├── leaflet-1.3.1/
    ├── leaflet-binding-2.1.1/
    ├── leaflet-providers-1.9.0/
    ├── leaflet-providers-plugin-2.1.1/
    ├── leafletfix-1.0.0/
    ├── proj4-2.6.2/
    ├── proj4js-2.3.15/
    ├── quarto-diagram/
    ├── quarto-html/
    └── rstudio_leaflet-1.3.1
```

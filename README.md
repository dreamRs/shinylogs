
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinylogs

> Logging tool for Shiny applications: record inputs or outputs changes,
> and infos about user’s session. All recording is done client-side to
> not slow down the application and occupy the server.

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/dreamRs/shinylogs.svg?branch=master)](https://travis-ci.org/dreamRs/shinylogs)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![version](http://www.r-pkg.org/badges/version/shinylogs)](https://CRAN.R-project.org/package=shinylogs)
[![cran
checks](https://cranchecks.info/badges/worst/shinylogs)](https://cranchecks.info/pkgs/shinylogs)
<!-- badges: end -->

## Installation

You can install the released version of shinylogs from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("shinylogs")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dreamRs/shinylogs")
```

## Usage

Call the main function `track_usage` in server part of application, and
specify where to write logs:

``` r
library(shinylogs)

track_usage(storage_mode = store_json(path = "logs/"))
```

The function will record :

  - *inputs* : each time an input change, name, timestamp and value will
    be saved
  - *errors* : errors propagated through outputs
  - *outputs* : each time an output is re-generated
  - *session* : informations about user’s browser and the application

See the vignette for more details (`?vignette("shinylogs")`) or the
[online
version](https://dreamrs.github.io/shinylogs/articles/shinylogs.html).

## Examples

Some example of what is recorded with logs from applications available
on our Shiny-Server: <http://shinyapps.dreamrs.fr/>

Number of connections per applications:

<img src="man/figures/connections-apps.png" width="100%" />

Number of connections over time :

<img src="man/figures/connections-day.png" width="100%" />

Which tabs (from sidebar in {shinydashboard}) in
[shinyWidgets](https://github.com/dreamRs/shinyWidgets) gallery are the
most seen :

<img src="man/figures/shinyWidgets-tabs.png" width="100%" />

User-agent is recorded per connection and can be parsed with
[uaparserjs](https://github.com/hrbrmstr/uaparserjs) : (unique users are
not registered as we use the open source version of shiny-server)

<img src="man/figures/ua-family.png" width="100%" /><img src="man/figures/ua-os.png" width="100%" />

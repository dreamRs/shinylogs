# shinylogs

> Record everything (almost) that happens in a 'Shiny' application browser side. Powered by [lowdb](https://github.com/typicode/lowdb).

[![Travis build status](https://travis-ci.org/dreamRs/shinylogs.svg?branch=master)](https://travis-ci.org/dreamRs/shinylogs)


:warning: This is experimental ! Feedback welcome !


## Installation

You can install from GitHub:

``` r
remotes::install_github("dreamRs/shinylogs")
```


## Usage

Call `track_usage` in your server function, it will record:

* *inputs* : each time an input change, name, timestamp and value will be saved
* *errors* : errors propagated through outputs
* *outputs* : each time an output is re-generated
* *session* : informations about the browser and the application

New inputs are created to expose those data, you can access them with `.shinylogs_input`, `.shinylogs_error`, `.shinylogs_output` and `.shinylogs_browserData`.
An additionnal input is also created to expose the last input modified by the user: `.shinylogs_lastInput`.

When application is closed (in fact on session ended), a JSON is created in a subfolder of app's directory.

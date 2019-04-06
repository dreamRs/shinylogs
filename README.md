# shinylogs

> Record everything (almost) that happens in a 'Shiny' application browser side. Powered by [localForage](https://github.com/localForage/localForage).

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


Example:

```r
# Shiny server
function(input, output, session) {

  track_usage(storage_mode = store_json(path = "logs/"))
  
}
```

Example of JSON created (with the [Kmeans example app](https://shiny.rstudio.com/gallery/kmeans-example.html))

```
{
   "inputs":{
      "input2m6NeSCL8OuaHaxzVpIHZ":{
         "name":"xcol",
         "timestamp":"2019-04-06T09:55:30+02:00",
         "value":"Petal.Width",
         "type":"",
         "binding":"shiny.selectInput"
      },
      "inputAhpPQmAJdNMLSqyk3m98x":{
         "name":"clusters",
         "timestamp":"2019-04-06T09:55:28+02:00",
         "value":5,
         "type":"shiny.number",
         "binding":"shiny.numberInput"
      },
      "inputBlVCReqTM8CIeLWTUSo5W":{
         "name":"ycol",
         "timestamp":"2019-04-06T09:55:36+02:00",
         "value":"Sepal.Width",
         "type":"",
         "binding":"shiny.selectInput"
      },
      "inputHH85n4k1PxfGZdbJtjWzR":{
         "name":"clusters",
         "timestamp":"2019-04-06T09:55:27+02:00",
         "value":4,
         "type":"shiny.number",
         "binding":"shiny.numberInput"
      },
      "inputNsCkymia4WPIGVLelcrvW":{
         "name":"ycol",
         "timestamp":"2019-04-06T09:55:24+02:00",
         "value":"Petal.Length",
         "type":"",
         "binding":"shiny.selectInput"
      },
      "inputhTiXAmKSLOcZYk1jdT8O9":{
         "name":"clusters",
         "timestamp":"2019-04-06T09:55:29+02:00",
         "value":5,
         "type":"shiny.number",
         "binding":"shiny.numberInput"
      },
      "inputv2N5ZSN6OYztLSzzCERMO":{
         "name":"xcol",
         "timestamp":"2019-04-06T09:55:22+02:00",
         "value":"Sepal.Width",
         "type":"",
         "binding":"shiny.selectInput"
      },
      "inputvID6EmzC3IAVRBH7G17we":{
         "name":"ycol",
         "timestamp":"2019-04-06T09:55:34+02:00",
         "value":"Species",
         "type":"",
         "binding":"shiny.selectInput"
      }
   },
   "errors":{
      "erroroj33WDsk86LqAC9Ve0QUU":{
         "name":"plot1",
         "timestamp":"2019-04-06T09:55:34+02:00",
         "error":"NA/NaN/Inf in foreign function call (arg 1)"
      }
   },
   "outputs":{
      "outputQMyfZdKESRVSvUxmrfsxM":{
         "name":"plot1",
         "timestamp":"2019-04-06T09:55:28+02:00",
         "binding":"shiny.imageOutput"
      },
      "outputbGFyAfvK3niwfFsr9q9Cb":{
         "name":"plot1",
         "timestamp":"2019-04-06T09:55:27+02:00",
         "binding":"shiny.imageOutput"
      },
      "outputfmScs2IjaCLwHGXgReBoD":{
         "name":"plot1",
         "timestamp":"2019-04-06T09:55:31+02:00",
         "binding":"shiny.imageOutput"
      },
      "outputhvd3UYhvXv8k7Fv2lqF41":{
         "name":"plot1",
         "timestamp":"2019-04-06T09:55:22+02:00",
         "binding":"shiny.imageOutput"
      },
      "outputmnUjmLE9wVgmLP4h19Lck":{
         "name":"plot1",
         "timestamp":"2019-04-06T09:55:25+02:00",
         "binding":"shiny.imageOutput"
      },
      "outputoDVdKNtCnY6yUmaDtVBvs":{
         "name":"plot1",
         "timestamp":"2019-04-06T09:55:36+02:00",
         "binding":"shiny.imageOutput"
      }
   },
   "session":[
      {
         "app":"kmeans-example",
         "user":"pvictor",
         "server_connected":"2019-04-06T09:55:20+0200",
         "sessionid":"cbbebc3cc14f3e0e832cf9d2de772ca3",
         "server_disconnected":"2019-04-06T09:55:38+0200",
         "user_agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36",
         "screen_res":"1920x1080",
         "browser_res":"949x917",
         "pixel_ratio":1,
         "browser_connected":"2019-04-06T09:55:21+02:00"
      }
   ]
}
```




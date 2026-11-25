# Record logs in shiny apps

``` r

library(shinylogs)
```

## How to use

Add in your server :

``` r

# server
track_usage(storage_mode = store_json(path = "logs/"))
```

It will store logs in a sub-folder `logs/` of your application.

If needed (in complex application), you can force dependencies in UI
with :

``` r

# UI
use_tracking()
```

## Storage modes

Four modes are available:

- [`store_json()`](https://dreamrs.github.io/shinylogs/reference/store_json.md)
  : store logs has separate JSON files (one by session).
- [`store_rds()`](https://dreamrs.github.io/shinylogs/reference/store_rds.md)
  : store logs has individually RDS files (one by session).
- [`store_sqlite()`](https://dreamrs.github.io/shinylogs/reference/store_sqlite.md)
  : store logs in a SQLite database.
- [`store_null()`](https://dreamrs.github.io/shinylogs/reference/store_null.md)
  : don’t write logs on disk, print them in R console.
- [`store_custom()`](https://dreamrs.github.io/shinylogs/reference/store_custom.md)
  : use a custom function to save logs wherever you want.
- [`store_googledrive()`](https://dreamrs.github.io/shinylogs/reference/store_googledrive.md)
  : store logs(as JSON files) in Googledrive.

## Deployment method

### Shiny server, RStudio Connect

On a server, if you want to save logs on disk, don’t forget to set write
permission on the folder you want to save logs.

On RStudio Connect, you need to use an absolute path to specify the
directory where to save logs. You can find more information here:
[Persistent Storage on RStudio
Connect](https://support.rstudio.com/hc/en-us/articles/360007981134-Persistent-Storage-on-RStudio-Connect)

### ShinyProxy

With [ShinyProxy](https://www.shinyproxy.io/), you can use a Docker
volume to write logs outside of the application container. In
`application.yml`, you can something like this in the specs describing
the application:

    container-volumes: [ "/var/log/shinylogs:/root/logs" ]

`/var/log/shinylogs` is a directory on the server where you deploy your
applications with ShinyProxy. `/root/logs` is a directory inside your
Docker image, it’s the path you can use in
[`track_usage()`](https://dreamrs.github.io/shinylogs/reference/track_usage.md),
e.g. :

``` r

track_usage(
  storage_mode = store_json(path = "/root/logs")
)
```

### shinyapps.io

There’s no persistent data storage on shinyapps.io, so you can’t save
logs as JSON or RDS files, you have to use a remote storage method. You
can use the builtin method provided to send logs in Googledrive with
`store_googledrive` or use `store_custom` to send logs wherever you want
(dropbox, remote database, …).

To use Googledrive, you’ll need to work with Google’s API and set auth
to your account, see [{gargle}
documentation](https://gargle.r-lib.org/index.html) for examples and how
to.

## Recorded informations

### Session

Those data are metadata about the application and the user’s browser,
here are the filed recorded :

- **app** : name of the application
- **user** : name of the user (if using Shiny-server pro for example)
- **server_connected** : timestamp of when application has been launched
  (server time)
- **sessionid** : a session ID to match the session with other recorded
  informations (inputs, outputs, errors)
- **server_disconnected** : timestamp of when the application was
  disconnected (server time)
- **user_agent** : browser user-agent
- **screen_res** : resolution of the user screen (width x height)
- **browser_res** : resolution of the user browser (width x height)
- **pixel_ratio** : pixel ratio of the browser
- **browser_connected** : timestamp of when application has been
  launched (browser time, depends on user timezone)

Example:

    #>            app    user    server_connected                        sessionid
    #> 1 iris-cluster dreamRs 2019-06-19 14:07:09 9815194cfaa6317fbea68ae9537d63d1
    #> 2 iris-cluster dreamRs 2019-06-19 14:56:32 0feeacf3201f5cca088059cec2b0a710
    #> 3 iris-cluster dreamRs 2019-06-19 14:57:45 8b12c138f159cc5805e136338dddac59
    #> 4 iris-cluster dreamRs 2019-06-19 15:03:00 f3950a1588b78d45c53c756a4136df67
    #> 5 iris-cluster dreamRs 2019-06-19 15:08:53 254cafb3d5866384f13022d066546cae
    #> 6 iris-cluster dreamRs 2019-08-04 10:58:47 8a431f4b90b3b1926047dd2539be0793
    #>   server_disconnected
    #> 1 2019-06-19 14:07:17
    #> 2 2019-06-19 14:57:39
    #> 3 2019-06-19 15:01:36
    #> 4 2019-06-19 15:08:13
    #> 5 2019-06-19 15:09:38
    #> 6 2019-08-04 10:58:49
    #>                                                                                                            user_agent
    #> 1 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36
    #> 2 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36
    #> 3 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36
    #> 4 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36
    #> 5 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36
    #> 6                                                                                                                <NA>
    #>   screen_res browser_res pixel_ratio   browser_connected
    #> 1  1920x1080    1574x724           1 2019-06-19 14:07:09
    #> 2  1920x1080    1920x937           1 2019-06-19 14:56:32
    #> 3  1920x1080    1920x937           1 2019-06-19 14:57:45
    #> 4  1920x1080    1920x937           1 2019-06-19 15:03:00
    #> 5  1920x1080    1920x937           1 2019-06-19 15:08:53
    #> 6       <NA>        <NA>          NA                <NA>

### Inputs

Data about inputs, by default all inputs are recorded (even those not
define by developper, like with {htmlwidgets} : {DT}, {leaflet}, …)

- **sessionid** : the same ID as in session object
- **name** : inputId of the input
- **timestamp** : timestamp when the input has changed
- **value** : the value taken by the input (can be a list in case of
  complex input)
- **type** : type of input (if defined)
- **binding** : binding for the input (if defined)

Example:

    #>                          sessionid     name           timestamp       value
    #> 1 9815194cfaa6317fbea68ae9537d63d1     xcol 2019-06-19 14:07:11 Sepal.Width
    #> 2 9815194cfaa6317fbea68ae9537d63d1 clusters 2019-06-19 14:07:15           6
    #> 3 9815194cfaa6317fbea68ae9537d63d1 clusters 2019-06-19 14:07:15           4
    #> 4 9815194cfaa6317fbea68ae9537d63d1 clusters 2019-06-19 14:07:15           5
    #> 5 9815194cfaa6317fbea68ae9537d63d1 clusters 2019-06-19 14:07:14           7
    #> 6 9815194cfaa6317fbea68ae9537d63d1 clusters 2019-06-19 14:07:13           4
    #>           type           binding
    #> 1         <NA> shiny.selectInput
    #> 2 shiny.number shiny.numberInput
    #> 3 shiny.number shiny.numberInput
    #> 4 shiny.number shiny.numberInput
    #> 5 shiny.number shiny.numberInput
    #> 6 shiny.number shiny.numberInput

### Outputs

Data recorded each time an output is refreshed :

- **sessionid** : the same ID as in session object
- **name** : outputId of the output
- **timestamp** : timestamp when the output has been updated
- **type** : type of output (if defined)
- **binding** : binding for the output (if defined)

Example:

    #>                          sessionid  name           timestamp           binding
    #> 1 9815194cfaa6317fbea68ae9537d63d1 plot1 2019-06-19 14:07:15 shiny.imageOutput
    #> 2 9815194cfaa6317fbea68ae9537d63d1 plot1 2019-06-19 14:07:15 shiny.imageOutput
    #> 3 9815194cfaa6317fbea68ae9537d63d1 plot1 2019-06-19 14:07:14 shiny.imageOutput
    #> 4 9815194cfaa6317fbea68ae9537d63d1 plot1 2019-06-19 14:07:15 shiny.imageOutput
    #> 5 9815194cfaa6317fbea68ae9537d63d1 plot1 2019-06-19 14:07:11 shiny.imageOutput
    #> 6 9815194cfaa6317fbea68ae9537d63d1 plot1 2019-06-19 14:07:10 shiny.imageOutput

### Errors

Errors are recorded only when propagated through an output, this is the
red message users see in application, infos saved are:

- **sessionid** : the same ID as in session object
- **name** : outputId of the output where an error happened
- **timestamp** : timestamp of the error
- **error** : error message (if any)
- **value** : additional data for the error (generally NULL) (if
  defined)

Example:

    #>                          sessionid  name           timestamp
    #> 1 f8f50a3743023aae7d0d6350a2fd6841 plot1 2019-06-19 14:07:18
    #>                                         error
    #> 1 NA/NaN/Inf in foreign function call (arg 1)

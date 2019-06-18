
#' @title Use JSON files as storage mode
#'
#' @description One JSON will be written for each session of the application.
#'
#' @param path Path where to write JSON files.
#'
#' @export
#'
#' @examples
#' if (interactive()) {
#'
#'   # temp directory for writing logs
#'   tmp <- tempdir()
#'
#'   # when app stop,
#'   # navigate to the directory containing logs
#'   onStop(function() {
#'     browseURL(url = tmp)
#'   })
#'
#'   # Classir Iris clustering with Shiny
#'   ui <- fluidPage(
#'
#'     headerPanel("Iris k-means clustering"),
#'
#'     sidebarLayout(
#'       sidebarPanel(
#'         selectInput(
#'           inputId = "xcol",
#'           label = "X Variable",
#'           choices = names(iris)
#'         ),
#'         selectInput(
#'           inputId = "ycol",
#'           label = "Y Variable",
#'           choices = names(iris),
#'           selected = names(iris)[[2]]
#'         ),
#'         numericInput(
#'           inputId = "clusters",
#'           label = "Cluster count",
#'           value = 3,
#'           min = 1,
#'           max = 9
#'         )
#'       ),
#'       mainPanel(
#'         plotOutput("plot1")
#'       )
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'
#'     # Store JSON with logs in the temp dir
#'     track_usage(
#'       storage_mode = store_json(path = tmp)
#'     )
#'
#'     # classic server logic
#'
#'     selectedData <- reactive({
#'       iris[, c(input$xcol, input$ycol)]
#'     })
#'
#'     clusters <- reactive({
#'       kmeans(selectedData(), input$clusters)
#'     })
#'
#'     output$plot1 <- renderPlot({
#'       palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
#'                 "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
#'
#'       par(mar = c(5.1, 4.1, 0, 1))
#'       plot(selectedData(),
#'            col = clusters()$cluster,
#'            pch = 20, cex = 3)
#'       points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
#'     })
#'
#'   }
#'
#'   shinyApp(ui, server)
#'
#' }
store_json <- function(path) {
  path <- normalizePath(path = path, mustWork = FALSE)
  if (!dir.exists(path))
    dir.create(path)
  store <- list(
    mode = "json",
    path = path
  )
  class(store) <- c(class(store), "shinylogs.storage_mode")
  return(store)
}



#' @title No storage on disk
#'
#' @description Doesn't write anything, special inputs created by \code{track_usage}
#'  are available in server and optionally logs are printed in console.
#'
#' @param console Print logs in R console.
#'
#' @export
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinylogs)
#'
#'   ui <- fluidPage(
#'     tags$h2("Record inputs change"),
#'     fluidRow(
#'       column(
#'         width = 3,
#'         selectInput(
#'           inputId = "select",
#'           label = "Select input",
#'           choices = month.name
#'         ),
#'         numericInput(
#'           inputId = "numeric",
#'           label = "Numerci input",
#'           value = 4,
#'           min = 0, max = 20
#'         ),
#'         checkboxGroupInput(
#'           inputId = "checkboxGroup",
#'           label = "Checkbox group input",
#'           choices = LETTERS[1:5]
#'         ),
#'         sliderInput(
#'           inputId = "slider",
#'           label = "Slider input",
#'           min = 0, max = 100, value = 50
#'         )
#'       ),
#'       column(
#'         width = 9,
#'         tags$b("Last input:"),
#'         verbatimTextOutput(outputId = "last_input"),
#'         tags$b("Last input:"),
#'         verbatimTextOutput(outputId = "all_inputs")
#'       )
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'
#'     track_usage(
#'       storage_mode = store_null() # dont store on disk
#'     )
#'
#'     output$last_input <- renderPrint({
#'       input$.shinylogs_lastInput # last input triggered
#'     })
#'
#'     output$all_inputs <- renderPrint({
#'       input$.shinylogs_input # all inputs that have changed
#'     })
#'
#'   }
#'
#'   shinyApp(ui, server)
#' }
store_null <- function(console = TRUE) {
  store <- list(
    console = console,
    mode = "null"
  )
  class(store) <- c(class(store), "shinylogs.storage_mode")
  return(store)
}



#' @title Use RDS files as storage mode
#'
#' @description One RDS will be written for each session of the application.
#'
#' @param path Path where to write RDS files.
#'
#' @export
#'
#' @examples
#' if (interactive()) {
#'
#'   # temp directory for writing logs
#'   tmp <- tempdir()
#'
#'   # when app stop,
#'   # navigate to the directory containing logs
#'   onStop(function() {
#'     browseURL(url = tmp)
#'   })
#'
#'   # Classir Iris clustering with Shiny
#'   ui <- fluidPage(
#'
#'     headerPanel("Iris k-means clustering"),
#'
#'     sidebarLayout(
#'       sidebarPanel(
#'         selectInput(
#'           inputId = "xcol",
#'           label = "X Variable",
#'           choices = names(iris)
#'         ),
#'         selectInput(
#'           inputId = "ycol",
#'           label = "Y Variable",
#'           choices = names(iris),
#'           selected = names(iris)[[2]]
#'         ),
#'         numericInput(
#'           inputId = "clusters",
#'           label = "Cluster count",
#'           value = 3,
#'           min = 1,
#'           max = 9
#'         )
#'       ),
#'       mainPanel(
#'         plotOutput("plot1")
#'       )
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'
#'     # Store RDS with logs in the temp dir
#'     track_usage(
#'       storage_mode = store_rds(path = tmp)
#'     )
#'
#'     # classic server logic
#'
#'     selectedData <- reactive({
#'       iris[, c(input$xcol, input$ycol)]
#'     })
#'
#'     clusters <- reactive({
#'       kmeans(selectedData(), input$clusters)
#'     })
#'
#'     output$plot1 <- renderPlot({
#'       palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
#'                 "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
#'
#'       par(mar = c(5.1, 4.1, 0, 1))
#'       plot(selectedData(),
#'            col = clusters()$cluster,
#'            pch = 20, cex = 3)
#'       points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
#'     })
#'
#'   }
#'
#'   shinyApp(ui, server)
#'
#' }
store_rds <- function(path) {
  path <- normalizePath(path = path, mustWork = FALSE)
  if (!dir.exists(path))
    dir.create(path)
  store <- list(
    mode = "rds",
    path = path
  )
  class(store) <- c(class(store), "shinylogs.storage_mode")
  return(store)
}



#' @title Use SQLite database as storage mode
#'
#' @description All logs will be written in the same file.
#'
#' @param path Path to the SQLite file or a directory where to create one.
#'
#' @export
#'
#' @examples
#' if (interactive()) {
#'
#'   # temp directory for writing logs
#'   tmp <- tempdir()
#'
#'   # when app stop,
#'   # navigate to the directory containing logs
#'   onStop(function() {
#'     browseURL(url = tmp)
#'   })
#'
#'   # Classir Iris clustering with Shiny
#'   ui <- fluidPage(
#'
#'     headerPanel("Iris k-means clustering"),
#'
#'     sidebarLayout(
#'       sidebarPanel(
#'         selectInput(
#'           inputId = "xcol",
#'           label = "X Variable",
#'           choices = names(iris)
#'         ),
#'         selectInput(
#'           inputId = "ycol",
#'           label = "Y Variable",
#'           choices = names(iris),
#'           selected = names(iris)[[2]]
#'         ),
#'         numericInput(
#'           inputId = "clusters",
#'           label = "Cluster count",
#'           value = 3,
#'           min = 1,
#'           max = 9
#'         )
#'       ),
#'       mainPanel(
#'         plotOutput("plot1")
#'       )
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'
#'     # Store RDS with logs in the temp dir
#'     track_usage(
#'       storage_mode = store_sqlite(path = tmp)
#'     )
#'
#'     # classic server logic
#'
#'     selectedData <- reactive({
#'       iris[, c(input$xcol, input$ycol)]
#'     })
#'
#'     clusters <- reactive({
#'       kmeans(selectedData(), input$clusters)
#'     })
#'
#'     output$plot1 <- renderPlot({
#'       palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
#'                 "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
#'
#'       par(mar = c(5.1, 4.1, 0, 1))
#'       plot(selectedData(),
#'            col = clusters()$cluster,
#'            pch = 20, cex = 3)
#'       points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
#'     })
#'
#'   }
#'
#'   shinyApp(ui, server)
#'
#' }
store_sqlite <- function(path) {
  path <- normalizePath(path = path, mustWork = FALSE)
  if (is_sqlite(path)) {
    if (!dir.exists(dirname(path)))
      dir.create(dirname(path))
  } else {
    if (!dir.exists(path))
      dir.create(path)
    path <- file.path(path, "shinylogs.sqlite")
  }
  store <- list(
    mode = "sqlite",
    path = normalizePath(path = path, mustWork = FALSE)
  )
  class(store) <- c(class(store), "shinylogs.storage_mode")
  return(store)
}


write_logs <- function(opts, logs) {
  if (opts$mode == "json") {
    write_logs_json(opts, logs)
  } else if (opts$mode == "rds") {
    write_logs_rds(opts, logs)
  } else if (opts$mode == "null") {
    invisible()
  } else if (opts$mode == "sqlite") {
    write_logs_sqlite(opts, logs)
  } else {
    stop("Not implemented!", call. = FALSE)
  }
}

#' @importFrom jsonlite write_json
write_logs_json <- function(opts, logs) {
  path <- file.path(
    opts$path,
    paste0("shinylogs_", opts$appname, "_", opts$timestamp, ".json")
  )
  jsonlite::write_json(x = logs, path = path, auto_unbox = TRUE)
  return(invisible(path))
}

write_logs_rds <- function(opts, logs) {
  path <- file.path(
    opts$path,
    paste0("shinylogs_", opts$appname, "_", opts$timestamp, ".rds")
  )
  saveRDS(object = logs, file = path)
  return(invisible(path))
}


#' @importFrom DBI dbConnect dbDisconnect dbWriteTable
#' @importFrom RSQLite SQLite
write_logs_sqlite <- function(opts, logs) {
  con <- DBI::dbConnect(drv = RSQLite::SQLite(), dbname = opts$path)
  on.exit(DBI::dbDisconnect(conn = con))
  lapply(
    X = names(logs),
    FUN = function(what) {
      value <- to_dt(list(logs), what, 1)
      if (!is.null(value)) {
        value$sessionid <- NULL
        value <- value[, lapply(.SD, function(x) {
          if (is.list(x)) {
            x <- I(lapply(x, serialize, connection = NULL))
          }
          x
        })]
        value <- as.data.frame(value)
        value$sessionid <- logs$session$sessionid
        DBI::dbWriteTable(conn = con, name = what, value = value, append = TRUE)
      }
    }
  )
  return(invisible(opts$path))
}




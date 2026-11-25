# Use JSON files as storage mode

One JSON will be written for each session of the application.

## Usage

``` r
store_json(path)
```

## Arguments

- path:

  Path where to write JSON files.

## Value

A list that can be used in
[`track_usage()`](https://dreamrs.github.io/shinylogs/reference/track_usage.md).

## Examples

``` r
library(shiny)
library(shinylogs)

# temp directory for writing logs
tmp <- tempdir()

# when app stop,
# navigate to the directory containing logs
onStop(function() {
  browseURL(url = tmp)
})
#> function () 
#> {
#>     .callbacks$remove(id)
#> }
#> <bytecode: 0x5eb8f29dc878>
#> <environment: 0x5eb8f5e26e58>

# Classic Iris clustering with Shiny
ui <- fluidPage(

  headerPanel("Iris k-means clustering"),

  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "xcol",
        label = "X Variable",
        choices = names(iris)
      ),
      selectInput(
        inputId = "ycol",
        label = "Y Variable",
        choices = names(iris),
        selected = names(iris)[[2]]
      ),
      numericInput(
        inputId = "clusters",
        label = "Cluster count",
        value = 3,
        min = 1,
        max = 9
      )
    ),
    mainPanel(
      plotOutput("plot1")
    )
  )
)

server <- function(input, output, session) {

  # Store JSON with logs in the temp dir
  track_usage(
    storage_mode = store_json(path = tmp)
  )

  # classic server logic

  selectedData <- reactive({
    iris[, c(input$xcol, input$ycol)]
  })

  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })

  output$plot1 <- renderPlot({
    palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
              "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))

    par(mar = c(5.1, 4.1, 0, 1))
    plot(selectedData(),
         col = clusters()$cluster,
         pch = 20, cex = 3)
    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
  })

}

if (interactive())
  shinyApp(ui, server)
```

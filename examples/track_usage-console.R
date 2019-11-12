
# Logs in console & special inputs ------------------------

if (interactive()) {
  library(shiny)
  library(shinylogs)

  ui <- fluidPage(
    tags$h2("Record inputs change"),
    fluidRow(
      column(
        width = 3,
        selectInput(
          inputId = "select",
          label = "Select input",
          choices = month.name
        ),
        numericInput(
          inputId = "numeric",
          label = "Numerci input",
          value = 4,
          min = 0, max = 20
        ),
        checkboxGroupInput(
          inputId = "checkboxGroup",
          label = "Checkbox group input",
          choices = LETTERS[1:5]
        ),
        sliderInput(
          inputId = "slider",
          label = "Slider input",
          min = 0, max = 100, value = 50
        )
      ),
      column(
        width = 9,
        tags$b("Last input triggered:"),
        verbatimTextOutput(outputId = "last_input"),
        tags$b("All inputs:"),
        verbatimTextOutput(outputId = "all_inputs")
      )
    )
  )

  server <- function(input, output, session) {

    # dont store on disk, just show in R console
    track_usage(
      storage_mode = store_null()
    )

    # last input triggered
    output$last_input <- renderPrint({
      input$.shinylogs_lastInput
    })

    # all inputs that have changed
    output$all_inputs <- renderPrint({
      input$.shinylogs_input
    })

  }

  shinyApp(ui, server)
}

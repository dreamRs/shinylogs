if (interactive()) {

  library(shiny)
  library(shinylogs)

  ui <- fluidPage(

    # Load tracking dependencies
    use_tracking(),

    splitLayout(
      cellArgs = list(style = "height: 250px"),
      radioButtons("radio", "Radio:", names(iris)),
      checkboxGroupInput("checkbox", "Checkbox:", names(iris)),
      selectInput("select", "Select:", names(iris))
    ),

    tags$p("Last input used, the 'name' slot correspond to inputId:"),
    verbatimTextOutput("last")
  )

  server <- function(input, output, session) {

    output$last <- renderPrint({
      input$.shinylogs_lastInput
    })

  }

  shinyApp(ui, server)

}

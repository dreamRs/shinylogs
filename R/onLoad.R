#' Shiny resource
#'
#' @importFrom shiny addResourcePath registerInputHandler
#'
#' @noRd
.onLoad <- function(...) {
  shiny::addResourcePath("shinylogs", system.file("assets", package = "shinylogs"))
  shiny::registerInputHandler("parse_logInput", parse_logInput)
  shiny::registerInputHandler("parse_lastInput", parse_lastInput)
}

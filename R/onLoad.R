#' Shiny resource
#'
#' @importFrom shiny addResourcePath registerInputHandler
#'
#' @noRd
.onLoad <- function(...) {
  shiny::registerInputHandler("parse_logInput", parse_logInput, force = TRUE)
  shiny::registerInputHandler("parse_lastInput", parse_lastInput, force = TRUE)
}

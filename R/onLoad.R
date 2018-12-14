#' Shiny resource
#'
#' @importFrom shiny addResourcePath registerInputHandler
#'
#' @noRd
.onLoad <- function(...) {
  shiny::addResourcePath("shinylogs", system.file("www", package = "shinylogs"))
  shiny::registerInputHandler("parse_log", parse_log)
}

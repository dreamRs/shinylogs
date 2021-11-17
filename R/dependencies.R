
#' @importFrom htmltools htmlDependency
#' @importFrom utils packageVersion
shinylogs_dependencies <- function() {
  htmlDependency(
    name = "shinylogs",
    version = packageVersion("shinylogs"),
    src = list(file = "packer"),
    package = "shinylogs",
    script = "shinylogs.js"
  )
}

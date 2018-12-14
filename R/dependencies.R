

#' @importFrom htmltools htmlDependency
shinylogs_dependencies <- function() {
  htmlDependency(
    name = "shinylogs", version = "0.0.1",
    src = list(href = "shinylogs", file = "www"), package = "shinylogs",
    script = c("js/shinylogs.js")
  )
}

#' @importFrom htmltools htmlDependency
lowdb_dependencies <- function() {
  htmlDependency(
    name = "lowdb", version = "1.8.3",
    src = list(href = "shinylogs", file = "www"), package = "shinylogs",
    script = c("lowdb/lodash.min.js", "lowdb/low.min.js", "lowdb/LocalStorage.min.js")
  )
}




#' @importFrom htmltools htmlDependency
shinylogs_ldb_dependencies <- function() {
  htmlDependency(
    name = "shinylogs", version = "0.0.1",
    src = list(href = "shinylogs", file = "assets"), package = "shinylogs",
    script = c("js/shinylogs-lowdb.js")
  )
}
shinylogs_lf_dependencies <- function() {
  htmlDependency(
    name = "shinylogs", version = "0.1.0",
    src = list(href = "shinylogs", file = "assets"), package = "shinylogs",
    script = c("js/shinylogs-localForage.js")
  )
}

#' @importFrom htmltools htmlDependency
lowdb_dependencies <- function() {
  htmlDependency(
    name = "lowdb", version = "1.8.3",
    src = list(href = "shinylogs", file = "assets"), package = "shinylogs",
    script = c("lowdb/lodash.min.js", "lowdb/low.min.js", "lowdb/LocalStorage.min.js")
  )
}

#' @importFrom htmltools htmlDependency
dayjs_dependencies <- function() {
  htmlDependency(
    name = "dayjs", version = "1.7.7",
    src = list(href = "shinylogs", file = "assets"), package = "shinylogs",
    script = c("dayjs/dayjs.min.js")
  )
}

#' @importFrom htmltools htmlDependency
localforage_dependencies <- function() {
  htmlDependency(
    name = "localForage", version = "1.7.3",
    src = list(href = "shinylogs", file = "assets"), package = "shinylogs",
    script = c("localForage/localforage.min.js", "localForage/localforage-getitems.js")
  )
}

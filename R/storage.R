
#' Use JSON files as storage mode
#'
#' @param path Path where to write JSON files.
#'
#' @export
#'
store_json <- function(path = "shinylogs") {
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


#' No storage on disk
#'
#' @export
#'
store_null <- function() {
  store <- list(
    mode = "null"
  )
  class(store) <- c(class(store), "shinylogs.storage_mode")
  return(store)
}


#' Use RDS files as storage mode
#'
#' @param path  Path where to write RDS files.
#'
#' @export
#'
store_rds <- function(path = "shinylogs") {
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


write_logs <- function(opts, logs) {
  if (opts$mode == "json") {
    write_logs_json(opts, logs)
  } else if (opts$mode == "rds") {
    write_logs_rds(opts, logs)
  } else if (opts$mode == "null") {
    invisible()
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
}

write_logs_rds <- function(opts, logs) {
  path <- file.path(
    opts$path,
    paste0("shinylogs_", opts$appname, "_", opts$timestamp, ".rds")
  )
  saveRDS(object = logs, file = path)
}

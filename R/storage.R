
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


write_logs <- function(opts, logs) {
  if (opts$mode == "json") {
    write_logs_json(opts, logs)
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
  jsonlite::write_json(x = logs, path = path)
}



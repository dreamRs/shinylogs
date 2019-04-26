
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
#' @param path Path where to write RDS files.
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



#' Use SQLite database as storage mode
#'
#' @param path Path to the SQLite file or a directory where to create one.
#'
#' @export
#'
store_sqlite <- function(path = "shinylogs") {
  path <- normalizePath(path = path, mustWork = FALSE)
  if (is_sqlite(path)) {
    if (!dir.exists(dirname(path)))
      dir.create(dirname(path))
  } else {
    if (!dir.exists(path))
      dir.create(path)
    path <- file.path(path, "shinylogs.sqlite")
  }
  store <- list(
    mode = "sqlite",
    path = normalizePath(path = path, mustWork = FALSE)
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
  } else if (opts$mode == "sqlite") {
    write_logs_sqlite(opts, logs)
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
  return(invisible(path))
}

write_logs_rds <- function(opts, logs) {
  path <- file.path(
    opts$path,
    paste0("shinylogs_", opts$appname, "_", opts$timestamp, ".rds")
  )
  saveRDS(object = logs, file = path)
  return(invisible(path))
}


#' @importFrom DBI dbConnect dbDisconnect dbWriteTable
#' @importFrom RSQLite SQLite
write_logs_sqlite <- function(opts, logs) {
  con <- DBI::dbConnect(drv = RSQLite::SQLite(), dbname = opts$path)
  on.exit(DBI::dbDisconnect(conn = con))
  lapply(
    X = names(logs),
    FUN = function(what) {
      value <- to_dt(list(logs), what, 1)
      if (!is.null(value)) {
        value$sessionid <- NULL
        value <- value[, lapply(.SD, function(x) {
          if (is.list(x)) {
            x <- I(lapply(x, serialize, connection = NULL))
          }
          x
        })]
        value <- as.data.frame(value)
        value$sessionid <- logs$session$sessionid
        DBI::dbWriteTable(conn = con, name = what, value = value, append = TRUE)
      }
    }
  )
  return(invisible(opts$path))
}




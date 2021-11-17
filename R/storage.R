
#' @title Use JSON files as storage mode
#'
#' @description One JSON will be written for each session of the application.
#'
#' @param path Path where to write JSON files.
#'
#' @return A list that can be used in [track_usage()].
#'
#' @export
#'
#' @example examples/store_json.R
store_json <- function(path) {
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



#' @title No storage on disk
#'
#' @description Doesn't write anything, special inputs created by [track_usage()]
#'  are available in server and optionally logs are printed in console.
#'
#' @param console Print logs in R console.
#'
#' @return A list that can be used in [track_usage()].
#'
#' @export
#'
#' @example examples/store_null.R
store_null <- function(console = TRUE) {
  store <- list(
    console = console,
    mode = "null"
  )
  class(store) <- c(class(store), "shinylogs.storage_mode")
  return(store)
}



#' @title Use RDS files as storage mode
#'
#' @description One RDS will be written for each session of the application.
#'
#' @param path Path where to write RDS files.
#'
#' @return A list that can be used in [track_usage()].
#'
#' @export
#'
#' @example examples/store_rds.R
store_rds <- function(path) {
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



#' @title Use SQLite database as storage mode
#'
#' @description All logs will be written in the same file.
#'
#' @param path Path to the SQLite file or a directory where to create one.
#'
#' @return A list that can be used in [track_usage()].
#'
#' @export
#'
#' @example examples/store_sqlite.R
store_sqlite <- function(path) {
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



#' @title Use Google Drive as storage mode
#'
#' @description All logs will be written in the same file.
#'
#' @param path Path to folder on Drive where to send logs.
#'
#' @return A list that can be used in [track_usage()].
#'
#' @note See the {gargle} package to manage authentication, and especially
#'  [this vignette from {gargle} package](https://gargle.r-lib.org/articles/articles/managing-tokens-securely.html) to manage the process.
#'
#' @export
#'
#'
#' @examples
#' \dontrun{
#' # In your global, manage Google Drive access
#' drive_auth(path = "/path/to/your/service-account-token.json")
#' # see https://gargle.r-lib.org/articles/articles/managing-tokens-securely.html
#' # to manage your token securely
#'
#' # Then in server, use:
#' track_usage(storage_mode = store_googledrive(path = "my-logs/"))
#'
#' # you may have to share my-logs/ folder with your service account
#'
#' }
store_googledrive <- function(path) {
  if (!requireNamespace(package = "googledrive"))
    message("store_googledrive: Package 'googledrive' is required to run this function")
  if (!googledrive::drive_has_token()) {
    warning("store_googledrive: no token for Google Drive API found, using store_null(console = TRUE) as fallback.")
    return(store_null(console = TRUE))
  }
  store <- list(
    mode = "googledrive",
    path = path
  )
  class(store) <- c(class(store), "shinylogs.storage_mode")
  return(store)
}


#' @title Use custom function to save logs
#'
#' @description Store logs tracked where you want by providing a custom
#'  function to write them in your prefered location.
#'
#' @param FUN A `function` that take at least one argument `logs`, that will correspond to logs recorded as a `list`.
#' @param ... Extra parameters that will be passed to `FUN`.
#'
#' @return A list that can be used in [track_usage()].
#' @export
#'
#' @example examples/store_custom.R
store_custom <- function(FUN, ...) {
  FUN <- match.fun(FUN)
  store <- list(
    mode = "custom",
    FUN = FUN,
    extra = list(...)
  )
  class(store) <- c(class(store), "shinylogs.storage_mode")
  return(store)
}



# Gather all methods ------------------------------------------------------

write_logs <- function(opts, logs) {
  if (opts$mode == "json") {
    write_logs_json(opts, logs)
  } else if (opts$mode == "rds") {
    write_logs_rds(opts, logs)
  } else if (opts$mode == "null") {
    invisible()
  } else if (opts$mode == "sqlite") {
    write_logs_sqlite(opts, logs)
  } else if (opts$mode == "googledrive") {
    write_logs_googledrive(opts, logs)
  } else if (opts$mode == "custom") {

    tryCatch(
      do.call(
        what = opts$FUN,
        args = c(list(logs = logs), opts$extra)
      ),
      error = function(e) {
        warning(
          "Error in writing logs with custom storage: ",
          e$message,
          call. = FALSE
        )
      }
    )

  } else {
    stop("Storage mode not implemented!", call. = FALSE)
  }
}



# Write methods -----------------------------------------------------------

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

#' @importFrom jsonlite write_json
write_logs_googledrive <- function(opts, logs) {
  if (!requireNamespace(package = "googledrive"))
    message("store_googledrive: Package 'googledrive' is required to run this function")
  path <- tempfile(fileext = ".json")
  jsonlite::write_json(x = logs, path = path, auto_unbox = TRUE)
  googledrive::drive_upload(
    media = path,
    path = opts$path,
    name = paste0("shinylogs_", opts$appname, "_", opts$timestamp, ".json")
  )
  return(invisible(opts$path))
}


write_logs_sqlite <- function(opts, logs) {
  if (!requireNamespace(package = "DBI"))
    message("store_sqlite: Package 'DBI' is required to run this function")
  if (!requireNamespace(package = "RSQLite"))
    message("store_sqlite: Package 'RSQLite' is required to run this function")
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




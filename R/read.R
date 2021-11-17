
#' Read a directory containing JSON logs
#'
#' @param path Path of the directory containing JSON files or a vector of path to JSON files.
#'
#' @return a `list` of `data.table`
#' @export
#'
#' @importFrom jsonlite fromJSON
#' @importFrom data.table rbindlist
#' @importFrom stats setNames
#'
#' @examples
#'
#' # Read all JSON in a directory
#' path_directory <- system.file("extdata/json", package = "shinylogs")
#' logs <- read_json_logs(path = path_directory)
#'
#' # Read a single file
#' single_file <- dir(
#'   path = system.file("extdata/json", package = "shinylogs"),
#'   full.names = TRUE
#' )[1]
#' logs <- read_json_logs(path = single_file)
#'
read_json_logs <- function(path) {
  read_logs(path = path, what = "json")
}



#' Read a directory containing RDS logs
#'
#' @param path Path of the directory containing RDS files or a vector of path to RDS files.
#'
#' @return a `list` of `data.table`
#' @export
#'
#' @importFrom jsonlite fromJSON
#' @importFrom data.table rbindlist
#' @importFrom stats setNames
#'
#' @examples
#' \dontrun{
#' # Read all RDS in a directory
#' logs <- read_rds_logs(path = "path/to/directory")
#'
#' # Read a single file
#' logs <- read_rds_logs(path = "path/to/log.rds")
#' }
read_rds_logs <- function(path) {
  read_logs(path = path, what = "rds")
}

read_logs <- function(path, what) {
  if (length(path) == 1 && dir.exists(path)) {
    files <- list.files(path = path, pattern = sprintf("\\.%s$", what), full.names = TRUE)
    files <- files[file.size(files) > 0]
    if (length(files) == 0) {
      stop(sprintf("No %s files to read in specified path", toupper(what)), call. = FALSE)
    }
  } else if (length(path) > 1) {
    files <- lapply(path, normalizePath, mustWork = TRUE)
  } else if (length(path) == 1 && grepl(pattern = paste0(what, "$"), x = path)) {
    files <- normalizePath(path, mustWork = TRUE)
  } else {
    stop(sprintf(
      "'path' must be either:\n - a directory containing %s files\n - a single %s file",
      toupper(what), toupper(what)
    ), call. = FALSE)
  }
  if (identical(what, "json")) {
    logs <- lapply(
      X = files,
      FUN = fromJSON
    )
  } else if (identical(what, "rds")) {
    logs <- lapply(
      X = files,
      FUN = readRDS
    )
  } else {
    stop("Not implemented", call. = FALSE)
  }
  session <- rbindlist(lapply(logs, `[[`, "session"), fill = TRUE)
  setTime(session)
  inputs <- to_dt(logs, "inputs", session$sessionid)
  setTime(inputs)
  errors <- to_dt(logs, "errors", session$sessionid)
  setTime(errors)
  outputs <- to_dt(logs, "outputs", session$sessionid)
  setTime(outputs)
  list(
    session = session,
    inputs = inputs,
    errors = errors,
    outputs = outputs
  )
}


#' @importFrom data.table rbindlist as.data.table
to_dt <- function(logs, what, sessionid) {
  l <- lapply(logs, `[[`, what)
  l <- lapply(l, function(x) {
    if (is.data.frame(x)) {
      if (is.data.frame(x$value)) {
        x$value <- apply(X = x$value, MARGIN = 1, FUN = as.list)
      }
      as.data.table(x)
    } else {
      rbindlist(lapply(setNames(x, NULL), function(y) {
        y$value <- list(y$value)
        as.data.table(y)
      }), fill = TRUE)
    }
  })
  rbindlist(l = setNames(l, sessionid), fill = TRUE, idcol = "sessionid")
}

#' @importFrom anytime anytime
#' @importFrom data.table :=
setTime <- function(data) {
  vars_time <- c("timestamp", "server_connected", "server_disconnected", "browser_connected")
  vars_time <- intersect(names(data), vars_time)
  if (length(vars_time) > 0) {
    data[, (vars_time) := lapply(.SD, anytime), .SDcols = vars_time]
  }
}

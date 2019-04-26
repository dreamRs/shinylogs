
#' Read a directory containing JSON logs
#'
#' @param path Path of the directory containing JSON files or a vector of path to JSON files.
#'
#' @return a list of \code{data.table}
#' @export
#'
#' @importFrom jsonlite fromJSON
#' @importFrom data.table rbindlist
#' @importFrom stats setNames
#'
read_json_logs <- function(path) {
  if (length(path) == 1 && dir.exists(path)) {
    jsons <- list.files(path = path, pattern = "\\.json$", full.names = TRUE)
    if (length(jsons) == 0) {
      stop("No JSON files to read in specified path", call. = FALSE)
    }
  } else if (length(path) > 1) {
    jsons <- lapply(path, normalizePath, mustWork = TRUE)
  } else if (length(path) == 1 &&grepl(pattern = "json$", x = path)) {
    jsons <- normalizePath(path, mustWork = TRUE)
  } else {
    stop("'path' must be a directory containing JSON files or a JSON file", call. = FALSE)
  }
  logs <- lapply(
    X = jsons,
    FUN = fromJSON
  )
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

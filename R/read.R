
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
    stop("'path' must be a directory containing JSON files or a a JSON file", call. = FALSE)
  }
  logs <- lapply(
    X = jsons,
    FUN = fromJSON
  )
  session <- rbindlist(lapply(logs, extract_dt, what = "session"), fill = TRUE)
  logs <- setNames(logs, session$sessionid)
  inputs <- rbindlist(lapply(logs, extract_dt, what = "inputs"), fill = TRUE, idcol = "sessionid")
  set_time(inputs)
  errors <- rbindlist(lapply(logs, extract_dt, what = "errors"), fill = TRUE, idcol = "sessionid")
  set_time(errors)
  outputs <- rbindlist(lapply(logs, extract_dt, what = "outputs"), fill = TRUE, idcol = "sessionid")
  set_time(outputs)
  list(
    session = session,
    inputs = inputs,
    errors = errors,
    outputs = outputs
  )
}

#' @importFrom data.table as.data.table :=
#' @importFrom anytime anytime
extract_dt <- function(x, what) {
  res <- x[[what]]
  if (!is.null(res)) {
    if (identical(what, "session")) {
      res <- as.data.table(res)
    } else {
      res <- rbindlist(lapply(res, as.data.table), fill = TRUE)
    }
    return(res)
  } else {
    NULL
  }
}


set_time <- function(data) {
  vars_time <- c("timestamp", "server_connected", "server_disconnected", "browser_connected")
  vars_time <- intersect(names(data), vars_time)
  if (length(vars_time) > 0) {
    data[, (vars_time) := lapply(.SD, anytime), .SDcols = vars_time]
  }
}

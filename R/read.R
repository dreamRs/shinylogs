
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
  list(
    session = session,
    inputs = rbindlist(lapply(logs, extract_dt, what = "inputs"), fill = TRUE, idcol = "sessionid"),
    errors = rbindlist(lapply(logs, extract_dt, what = "errors"), fill = TRUE, idcol = "sessionid"),
    outputs = rbindlist(lapply(logs, extract_dt, what = "outputs"), fill = TRUE, idcol = "sessionid")
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
    vars_time <- c("timestamp", "server_connected", "server_disconnected", "browser_connected")
    vars_time <- intersect(names(res), vars_time)
    if (length(vars_time) > 0) {
      res[, (vars_time) := lapply(.SD, anytime), .SDcols = vars_time]
    }
    return(res)
  } else {
    NULL
  }
}



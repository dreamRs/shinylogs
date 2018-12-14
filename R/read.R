
#' Read a directory containing JSON logs
#'
#' @param path Path of the directory containing JSON files.
#'
#' @return a list of \code{data.table}
#' @export
#'
#' @importFrom jsonlite read_json
#' @importFrom data.table rbindlist
#' @importFrom stats setNames
#'
read_json_logs <- function(path) {
  jsons <- list.files(path = path, pattern = "\\.json$", full.names = TRUE)
  if (length(jsons) == 0) {
    stop("No JSON files to read in specified path", call. = FALSE)
  }
  logs <- lapply(
    X = jsons,
    FUN = read_json
  )
  user <- rbindlist(lapply(logs, extract_dt, what = "user"), fill = TRUE)
  logs <- setNames(logs, user$sessionid)
  list(
    user = user,
    inputs = rbindlist(lapply(logs, extract_dt, what = "inputs"), fill = TRUE, idcol = "sessionid"),
    errors = rbindlist(lapply(logs, extract_dt, what = "errors"), fill = TRUE, idcol = "sessionid"),
    outputs = rbindlist(lapply(logs, extract_dt, what = "outputs"), fill = TRUE, idcol = "sessionid")
  )
}

#' @importFrom data.table as.data.table :=
extract_dt <- function(x, what) {
  res <- x[[what]]
  if (!is.null(res)) {
    res <- rbindlist(lapply(res, as.data.table))
    if (!is.null(res$timestamp)) {
      res[, timestamp := as.POSIXct(timestamp/1000, origin = "1970-01-01")]
    }
    return(res)
  } else {
    NULL
  }
}



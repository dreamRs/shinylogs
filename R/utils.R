
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE = logical(1))]
}


get_timestamp <- function(time = NULL) {
  if (is.null(time))
    time <- Sys.time()
  tz_ <- format(time, format = "%z")
  attr(time, "tzone") <- "UTC"
  time_ <- format(time, format = "%Y-%m-%dT%H:%M:%S")
  paste0(time_, tz_)
}




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


parse_browser_data <- function(dat) {
  dat <- as.data.frame(dat, stringsAsFactors = FALSE)
  dat$browser_connected <- as.numeric(dat$browser_connected)
  dat$browser_connected <- as.POSIXct(dat$browser_connected/1000, origin = "1970-01-01")
  dat$browser_connected <- get_timestamp(dat$browser_connected)
  dat
}


dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE = logical(1))]
}

get_timestamp <- function(time = NULL) {
  if (is.null(time))
    time <- Sys.time()
  format(time, format = "%Y-%m-%d %H:%M:%OS3%z")
}

is_sqlite <- function(path) {
  is.character(path) && grepl(pattern = "\\.sqlite$", x = path)
}

get_user_ <- function(session) {
  if (!is.null(session$user))
    return(session$user)
  user <- Sys.getenv("SHINYPROXY_USERNAME")
  if (!identical(user, "")) {
    return(user)
  } else {
    getOption("shinylogs.default_user", default = Sys.info()[["user"]])
  }
}

#' @importFrom jsonlite toJSON
to_console <- function(obj, ...) {
  if (!is.null(obj)) {
    json <- jsonlite::toJSON(
      x = c(obj, ...),
      pretty = TRUE, auto_unbox = TRUE
    )
    print(json)
  }
}

context("test-tracking")

test_that("track_usage works", {

  session <- as.environment(list(
    ns = identity,
    # listInsertUI = list(),
    sendInputMessage = function(inputId, message) {
      session$lastInputMessage = list(id = inputId, message = message)
    },
    sendInsertUI = function(selector, multiple, where, content) {
      session$listInsertUI = c(
        session$listInsertUI,
        list(list(selector = selector, multiple = multiple,
             where = where, content = content))
      )
    },
    onFlushed = function(callback, once = TRUE) {
      callback()
    },
    onSessionEnded = function(fun) {
      session$funOnSessionEnded <- fun
    }
  ))

  tracking <- track_usage(
    storage_mode = store_null(),
    on_unload = FALSE,
    exclude_input_regex = "^\\.",
    session = session
  )

  expect_is(session$funOnSessionEnded, "function")
  expect_length(session$listInsertUI, 2)
})



test_that("to_console works", {

  expect_output(to_console(list(a = 1)), "\"a\": 1")

})




context("test-read-json")

dir_json <- system.file("testdata", package = "shinylogs")
files_json <- list.files(path = dir_json, pattern = "\\.json$", full.names = TRUE)

test_that("read single json log works", {

  logs <- read_json_logs(path = files_json[1])

  expect_is(logs, "list")
  expect_length(logs, 4)
  expect_is(logs$inputs, "data.table")
})


test_that("read directory of logs works", {

  logs <- read_json_logs(path = dir_json)

  expect_is(logs, "list")
  expect_length(logs, 4)
  expect_is(logs$inputs, "data.table")
})


test_that("no logs to read works", {

  expect_error(read_json_logs(path = tempdir()))

})


test_that("read multiple json logs works", {

 logs <- read_json_logs(path = files_json)

  expect_is(logs, "list")
  expect_length(logs, 4)
  expect_is(logs$inputs, "data.table")
})

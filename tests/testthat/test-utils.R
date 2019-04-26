context("test-utils")

test_that("dropNulls works", {

  l <- list(a = 1, b = NULL)

  expect_length(dropNulls(l), 1)
})

test_that("get_timestamp works", {

  ts <- get_timestamp(Sys.Date())

  expect_is(ts, "character")
})

test_that("is_sqlite works", {

  expect_true(is_sqlite("path/to/log.sqlite"))
  expect_false(is_sqlite("path/to/log.json"))
})

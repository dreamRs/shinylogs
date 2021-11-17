context("test-storage")

test_that("store_json works", {

  storage <- store_json(path = tempdir())

  expect_is(storage, "shinylogs.storage_mode")
  expect_identical(storage$mode, "json")
})

test_that("store_null works", {

  storage <- store_null()

  expect_is(storage, "shinylogs.storage_mode")
  expect_identical(storage$mode, "null")
})

test_that("store_rds works", {

  storage <- store_rds(path = tempdir())

  expect_is(storage, "shinylogs.storage_mode")
  expect_identical(storage$mode, "rds")
})

test_that("store_sqlite works", {

  testthat::skip_if_not_installed("DBI")
  testthat::skip_if_not_installed("RSQLite")

  storage <- store_sqlite(path = tempdir())

  expect_is(storage, "shinylogs.storage_mode")
  expect_identical(storage$mode, "sqlite")
})


test_that("write_logs (sqlite) works", {

  samplelogs <- readRDS(file = system.file("testdata/samplelog.rds", package = "shinylogs"))
  tmp <- tempdir()
  storage <- store_sqlite(path = tmp)

  out <- write_logs(opts = storage, logs = samplelogs)
  on.exit(unlink(out))

  expect_true(file.exists(out))
  expect_true(is_sqlite(out))
})


test_that("write_logs (json) works", {

  samplelogs <- readRDS(file = system.file("testdata/samplelog.rds", package = "shinylogs"))
  tmp <- tempdir()
  storage <- store_json(path = tmp)

  out <- write_logs(opts = storage, logs = samplelogs)
  on.exit(unlink(out))

  expect_true(file.exists(out))
})

test_that("write_logs (rds) works", {

  samplelogs <- readRDS(file = system.file("testdata/samplelog.rds", package = "shinylogs"))
  tmp <- tempdir()
  storage <- store_rds(path = tmp)

  out <- write_logs(opts = storage, logs = samplelogs)
  on.exit(unlink(out))

  expect_true(file.exists(out))
})



context("test-use_tracking")

test_that("use_tracking works", {

  track <- use_tracking()

  expect_is(track, "shiny.tag")
  expect_is(htmltools::findDependencies(track), "list")
  expect_true(length(htmltools::findDependencies(track)) > 0)
})

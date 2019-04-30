context("test-dependencies")

test_that("dependencies works", {

  deps <- htmltools::resolveDependencies(list(
    shinylogs_lf_dependencies(),
    dayjs_dependencies(),
    localforage_dependencies()
  ), resolvePackageDir = FALSE)


  expect_is(deps, "list")
  expect_length(deps, 3)
})

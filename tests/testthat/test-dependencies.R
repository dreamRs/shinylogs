context("test-dependencies")

test_that("dependencies works", {

  deps <- htmltools::resolveDependencies(list(
    shinylogs_ldb_dependencies(),
    shinylogs_lf_dependencies(),
    lowdb_dependencies(),
    dayjs_dependencies(),
    localforage_dependencies()
  ), resolvePackageDir = FALSE)


  expect_is(deps, "list")
  expect_length(deps, 4)
})

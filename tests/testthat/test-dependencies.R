context("test-dependencies")

test_that("dependencies works", {

  deps <- htmltools::resolveDependencies(list(
    shinylogs_dependencies()
  ), resolvePackageDir = FALSE)


  expect_is(deps, "list")
  expect_length(deps, 1)
})

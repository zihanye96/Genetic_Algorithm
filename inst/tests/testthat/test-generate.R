context("Tests for Generate")

test_that("generate works with normal input", {
  c <- 10
  p <- 15

  # returns a list of numeric vectors
  expect_is(generate(c, p), "list")
  expect_is(generate(c, p)[[1]], "integer")

  # returns list of length p with each vector of length c
  expect_length(generate(c, p), p)
  expect_length(generate(c, p)[[1]], c)
})


test_that("generate does not create all zero vectors", {
  c <- 1000
  p <- 10000

  # ensure not all of the sequences are all zero's
  expect_false(all(sapply(generate(c, p), function(x) all(x == 0)), TRUE))
})

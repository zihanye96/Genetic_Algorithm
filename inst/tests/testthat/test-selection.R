context("Tests for selection")

c <- 10
p <- 14
mods <- generate(c,p)
criterion <- "AIC"
family <- "gaussian"
response <- "mpg"
covariates <- c("cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb")
data <- mtcars
testmod <- selection(p, mods, response, covariates, data, criterion, family)

test_that("The returned object is a nested list",{
  expect_is(testmod, "list")
})

test_that("the length of returned object should have length of p/2", {
  expect_length(testmod, p/2)
})

test_that("each of the pairs has a length of 2", {
  for (pair in testmod){
    expect_length(pair, 2)
  }
})

test_that("objects in a pair is equal in length", {
  for (pair in testmod){
    expect_equal(length(pair[1]), length(pair[2]))
  }
})

test_that("selection() can utilize other objective functions",{
  criterionB <- "BIC"
  testmodB <- selection(p, mods, response, covariates, data, criterionB, family)
  expect_is(testmodB, "list")
})


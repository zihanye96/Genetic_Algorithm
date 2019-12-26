context("Tests for select")

test_that("select works with normal input", {
  response <- "mpg"
  covariates <- names(mtcars)[-which(names(mtcars) == response)]

  # returns output of class list
  expect_type(select(mtcars, response, covariates), "list")
})

test_that("select works with fewer covariates", {
  response <- "mpg"
  covariates <- names(mtcars)[-which(names(mtcars) == response)]

  # ensure function works using fewer covariates
  expect_type(select(mtcars, response, covariates[4:8]), "list")
})


test_that("select works with another regression model", {
  response <- "vs"
  covariates <- names(mtcars)[-which(names(mtcars) == response)]
  logistic_mod <- select(mtcars, response, covariates, family = "binomial")

  # ensure function works on another glm family
  expect_type(logistic_mod, "list")
})

# formal test to compare algorithm to some known truth
test_that("select does not output a model that includes an unrelated covariate", {

  # generate mtcars data with an extra variable that is not correlated
  data <- cbind(mtcars, fake_var = rnorm(nrow(mtcars), 0, 1))

  # run function and extract selected covariates
  nIter <- 20
  coef <- vector(mode = "list", length = nIter)
  
  for(i in 1:nIter){
    result <- select(data, names(data)[1], names(data)[-1])
    coef[[i]] <- result$coefficients["fake_var"] 
  }
  
  
  # a list of whether or not the unrelated variable was selected in the models
  boolean <- is.na(coef)
  
  # proportion of times the unrelated variable was not found in the model
  propExclude <- sum(boolean)/nIter
  excludesEnough <- propExclude > .5
  
  expect_true(excludesEnough)
})

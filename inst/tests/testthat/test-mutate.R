context("Tests for mutate")

mod <- as.integer(c(1,0,1,1,0,1,0))
mutedobj <- mutate(mod, 10)

test_that("Mutation doesn't change the length of the object",{
  expect_equal(length(mod), length(mutedobj))
})

test_that("Mutation doesn't change the type of the object",{
  expect_equal(typeof(mod), typeof(mutedobj))
  expect_is(mutedobj, "integer")
  
})
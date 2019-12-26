context("Tests for crossover")

test_that("crossover function returns an object with length 2",{
  mods <- generate(10, 14)
  parents <- c(length(mods), length(mods)/2)
  offsprings <- crossover(parents, mods)

  expect_length(offsprings, 2)
})


test_that("crossover function doesn't change the length of the models",{
  c <- 10
  mods <- generate(c, 14)
  parents <- c(length(mods), length(mods)/2)
  offsprings <- crossover(parents, mods)

  expect_equal(length(offsprings[[1]]), c)
  expect_equal(length(offsprings[[2]]), c)
})


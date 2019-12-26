
#' @export
crossover <- function(parents, mods) {

  ## crossover() takes a vector of 2 indices (parents) and a list of models (mods)
  ## and performs the crossover operator on the models corresponding to the 2 indices
  ## returns a list of 2 numeric vectors

  ## parents[i] is the index of the model (1,...p) that we're using for the crossover
  parent1 <- mods[[parents[1]]]
  parent2 <- mods[[parents[2]]]

  ## randomly find a split point
  length <- length(parent1)
  split <- sample(1:(length-1), 1)

  ## create offsprings
  offspring1 <- c(parent1[1:split], parent2[(split+1):length])
  offspring2 <- c(parent2[1:split], parent1[(split+1):length])

  ## perform the crossover and return results
  results <- list(offspring1, offspring2)
  return(results)

}

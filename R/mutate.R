#' @export

mutate <- function(chrome, c){

  ## mutate() takes a single chromosome and mutates each bit with a low probability
  ## chrome is the chromosome to mutate, c is the chromosome length
  ## returns the mutated chromosome

  ## prob is the probability of mutation at each locus independently
  prob <- 1/c

  ## mutate a given bit in the chromosome with probability 1/c
  mutBit <- function(x){

    as.integer(sample(c(x, 1-x), size = 1, prob = c(1-prob, prob)))

  }

  ## perform the mutation operator on the chromosome
  mutChrome <- sapply(chrome, mutBit)
  
  ## if the chromosome contains all 0's, mutate again until it doesn't
  ## so that the algorithm can continue
  
  while(sum(mutChrome)==0){
    mutChrome <- sapply(mutChrome, mutBit)
  }

  return(mutChrome)
}


#' @export
generate <- function(c, p){

  ## generate() generates a list of p chromosomes of length c
  ## p is the size of the total number of chromesome generated (generation size)
  ## c is the size of each chromesome

  mods <- vector(mode="list", p)

  for(i in 1:p){
    mods[[i]] <- as.integer(sample(c(1,0), size=c, replace=TRUE, prob=c(.8,.2)))
  }

  return(mods)
}

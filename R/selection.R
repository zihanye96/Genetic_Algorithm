
#' @export
selection <- function(p, mods, response, covariates, data, criterion, family, maximize = FALSE){

  ## selection() takes a list p of models from the previous iteration
  ## and outputs p/2 pairs of "parents" to do genetic operation on


  ## initialize a vector to store objective function values
  ## first column represents model index in the list "mods"
  value <- cbind(1:p, rep(0, length=p), rep(0, length=p), rep(0, length=p))

  ## compute objective function values for each model
  for(i in 1:p){

    vars <- covariates[which(mods[[i]]==1)] # get a vector of the covariates we're fitting
    formula <- as.formula(
      paste(response,
            paste(vars, collapse = " + "),
            sep = " ~ "))
    mod <- glm(formula, data = data, family = family)

    ## returns the value (rank) based on criterion and assigns to second column
    value[i,2] <- match.fun(criterion)(mod)

  }

  ## assign a rank to the model based on objective function value
  ## for AIC, the lower the better, so the model will get higher rank
  value <- value[order(value[,2], decreasing = !maximize),]

  ## assign a rank to each model from 1 to p, with p being the best
  value[,3] <- 1:p

  ## compute probability weight for each model based on rank
  for(i in 1:p){

    fitness <- 2*value[i,3]/(p*(p+1))
    value[i,4] <- fitness

  }

  ## pair up the model based on probability for a total of p/2 pairs
  ## both parents is selected with probability proportional to fitness
  ## the other parent is selected completely at random
  parent1 <- sample(value[,1], size=p/2, prob=value[,4], replace=TRUE)
  parent2 <- sample(value[,1], size=p/2, replace=TRUE)


  ## return a list of p/2 pairs
  pairs <- mapply(c, parent1, parent2, SIMPLIFY = FALSE)
  return(pairs)
}

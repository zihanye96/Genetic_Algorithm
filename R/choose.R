
#' @export
choose <- function(p, candidates, response, covariates, data, criterion, family, maximize = FALSE) {

  ## choose() takes in a list of candidate models/chromosomes, the response variable, covariates,
  ## and objective criterion and outputs the "best" model.
  ## maximize indicates whether or not we should maximize the objective criterion
  ## family is the family parameter to specify in glm()


  ## initialize a vector to store objective function values
  ## first column represents model index in the list "mods"
  value <- cbind(1:p, rep(0, length=p))
  mods <- vector(mode="list", p)

  ## compute objective function values for each model
  for(i in 1:p){

    ## fit model for each candidate chromosome

    vars <- covariates[which(candidates[[i]]==1)] # get a vector of the covariates we're fitting
    formula <- as.formula(
      paste(response,
            paste(vars, collapse = " + "),
            sep = " ~ "))
    mod <- glm(formula, data = data, family = family)

    ## compute the value (rank) based on criterion and assigns to second column
    value[i,2] <- match.fun(criterion)(mod)

    mods[[i]] <- mod
  }

  ## assign a rank to the model based on objective function value
  ## for AIC, the lower the better, so the model will get higher rank
  fittest <- value[order(value[,2], decreasing = maximize),][1]
  bestSeq <- candidates[[fittest]]
  bestMod <- mods[[fittest]]

  results <- list()
  results$sequence <- bestSeq # fittest chromosome sequence
  results$model <- bestMod # best model corresponding to that sequence
  results$fitness <- value[fittest,2] # corresponding fitness score
  return(results)
}

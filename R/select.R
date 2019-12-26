#' Select best regression model using genetic algorithm
#'
#' \code{select} implements a genetic algorithm for variable selection in regression and returns
#' the regression model selected by the genetic algorithm.
#'
#' This implementation of the genetic algorithm uses generation size p = ceiling(1.5*c/2)*2
#' where c is the length of the chromosomes (i.e. the number of covariates to consider in the model).
#' The parent chromosomes are selected via rank-based selection, where the probability of a chromosome
#' being selected as parent 1 is proportional to its relative rank, = 2r/(p*(p+1)), where r is the relative rank
#' (higher is better). Parent 1 is selected with these probabilities, and parent 2 is selected completely
#' at random.
#' Each chromosome is mutated with probability 1/c, which has been supported by theoretical work and
#' empirical studies.
#' The algorithm will stop when the objective criterion score (AIC by default) converges absolutely, i.e.
#' when the absolute difference between the score from iteration i-1 and the score from iteration i is less
#' than .000001, the algorithm stops and returns the best model from iteration i of the algorithm.
#'
#' @param data The dataset to perform regression on.
#' @param response A character string of the name of the response variable.
#' @param covariates A character vector of names of the predictor variables (covariates).
#' @param criterion AIC by default, but user can provide their own
#' @param family a character string naming a family function to use in the model (passed to glm)
#'   common families include "gaussian" (identity link), "binomial" (logit link), "poisson" (log link)
#' @return The regression model selected by the genetic algorithm. This is an object of class "glm" and "lm"
#' @export
#' @examples
#' data <- mtcars
#' response <- names(mtcars)[1]
#' covariates <- names(mtcars)[-1]
#' select(data, response, covariates)
#'
#' # How to perform logistic regression with select()
#' response <- "am"
#' covariates <- c("mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "gear", "carb")
#' select(data, response, covariates, family = "binomial")
#'
#' # You can also use another objective function instead of AIC (default)
#' response <- "mpg"
#' covariates <- c("cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am")
#' select(data, response, covariates, criterion="BIC")

select <- function(data, response, covariates, criterion="AIC", family = "gaussian", maximize=FALSE){

  ## select() takes the data, response, and covariates for regression and returns the
  ## model selected by the genetic algorithm
  ## criterion can be any objective criterion (AIC by default)
  ## family is the input to pass to glm()'s family argument (gaussian means linear regression)
  ## maximize indicates whether or not we should maximize the objective criterion


  ## update data to remove any columns for covariates the user didn't specify
  if(length(covariates)<ncol(data)-1){

    data <- subset(data, select = c(response, covariates))

  }

  c <- length(covariates)
  p <- ceiling(1.5*c/2)*2 # this will be an even number c and 2c

  ## initialize a list of models
  mods <- generate(c,p)

  prevScore <- 0
  currentScore <- 1000000
  i <- 0

  while(abs(prevScore-currentScore)>1e-6){

    ## select pairs of parents to do crossover and do crossover
    parents <- selection(p, mods, response, covariates, data, criterion, family=family)
    crossed <- lapply(parents, crossover, mods=mods)

    ## unlist the lists of crossed models so that we have a list of crossed models
    ## instead of a list of lists (each element containing 2 models)
    crossed <- unlist(crossed, recursive = FALSE)

    ## mutate each individual chromosome
    mutated <- lapply(crossed, mutate, c)

    ## choose the best chromosome in this generation
    best <- choose(p, mutated, response, covariates, data,
                   criterion, family= family, maximize = maximize)

    prevScore <- currentScore
    currentScore <- best$fitness

    bestMod <- best$model

    i <- i+1 # update index

  }

  ## print out relevant information regarding the algorithm
  cat("Objective Function Score At Final Iteration:", currentScore, "\n",
      "Objective Function Score At Penultimate Iteration:", prevScore, "\n",
      "Number of Iterations:", i, "\n")

  ## return the model selected by the genetic algorithm
  return(bestMod)
}

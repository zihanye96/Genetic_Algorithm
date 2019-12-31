

# Genetic Algorithm for Variable Selection in Regression

This package implements a genetic algorithm for variable selection in regression using the guidelines outlined in [Chapter 3](https://github.com/zihanye96/Genetic_Algorithm/blob/master/givens_hoeting_ch3.pdf) of *Computational Statistics* by Geof H. Givens and Jennifer A. Hoeting. The package includes modular functions that are designed to execute individual steps in the algorithm, and the main function, **select()**, utilizes these modular functions to output the "best" regression model using the inputs provided by the user (more below). This package was created in collaboration with Asem Berkalieva and Jing Xu for STAT 243 (Statistical Computing) at UC Berkeley.  

## Overview

The main function, select(), will take 6 inputs:      

1. The object corresponding to the dataset being used.             

2. A character string corresponding to the name of the response variable the user would like to model.

3. A vector of the character strings of names of the predictor variables (covariates) that the user would like to consider using. This allows the user to directly leave out certain information in the dataset that they don't consider to be useful in prediction.         

4. A character string corresponding to the name of the objective criterion/fitness function that will be used to evaluate each model. By default, the function uses "AIC", but the user can use other objective criterion available in base R (ex. BIC) or write their own fitness function.      

5. A character string corresponding to the type of regression the user would like to perform. By default, the function uses "Gaussian", which is the default identity link that's equivalent to performing standard linear regression. However, the user can specify other families, such as binomial, which uses a logit link by default and allows the user to perform logistic regression. The user can specify any family that is accepted by the glm() function.      

6. A boolean variable called "maximize", indicating whether the objective criterion should be maximized or minimized. For example, if the objective criterion select() is using is written by the user and the user would like to maximize this objective criterion (instead of minimize, as one would if the objective criterion were AIC), they can specify "maximize = TRUE" as an input. By default, maximize is false.     

Using these inputs, select() will run a genetic algorithm and return the regression model at the final iteration of the algorithm.


## Functions   
Here are the functions that used to implement the algorithm:            

### Generate

The generate() function initializes a list of p sequences (consisting of 0's and 1's), which each sequence representing a regression model. We will refer to the list of p sequences as a "generation". The length of the sequence is equal to the number of covariates that the user would like to consider using in the regression model. A 0 in the 1st number in the sequence means the model won't use the 1st covariate, and a 1 in the 3rd number in the sequence means the model will use the 3rd covariate. The number of sequences generated, p, is determined by the select() function (more details in the "Select" section). We chose to generate a "1" in a given sequence with higher probability than "0" because we want to initialize models that include more covariates (rather than leaving out more covariates). This will also avoid the problem of having sequences that contain only 0's, which is useless in the context of regression since one cannot fit a model without any covariates.     


### Selection

The selection() function takes as input a generation (list) of p sequences and outs p/2 pairs of "parents", with each pair being a numeric vector of 2 index values, each corresponding to a sequence in the input. We chose to select one parent with probability proportional to fitness and one parent completely at random, which will reduce the chance of one parent dominating the gene pool at early iterations of the algorithm and cause the algorithm to converge prematurely. We used a rank-based method for selection by ranking each model based on the objective criterion (which is AIC by default). In other words, the higher rank a given sequence has, the more likely it is to be chosen as parent 1. Parent 2 is chosen completely at random, so each sequence has an equal chance of being selected as parent 2.     

### Crossover     

The crossover() function takes as input a numeric vector of two index values and performs the crossover genetic operator on the 2 "parent" sequences in the generation corresponding to those two index values. Let c be the length of a sequence in this problem. To achieve this, we chose a splitting point to split the sequences. The splitting point will be a value between 1 and c-1, randomly drawn with equal probability. If the value of the splitting point is 2, then the function will split each sequence into two parts, with one part consisting of the sequence up to (and including) the 2nd bit and one part consisting of the sequence after (not including) the second bit. As a result, the function splits each sequence into parts A and B. To generate "child" sequences from the "parent" sequences, the function concatenates part A of sequence 1 with part B of sequence 2 to create the first child and does the same with part A of sequence 2 with part B of sequence 1 to create the second child.     


### Mutate      

The mutate() function takes as input a sequence of length c and mutates each bit in the sequence with probability 1/c. We chose the mutation rate of 1/c because theoretical work and empirical studies have supported a rate of 1/c. If after mutating a chromosome, the chromosome contains all 0's, then the function repeats the mutation process until the chromosome doesn't contain all 0's, as it's not possible to fit a model with no covariates.          

### Choose      

The choose() function takes as input a list of mutated sequences and returns the "best" sequence in that generation in terms of objective criterion score, along with its objective criterion score and the model object of the regression model corresponding to that sequence. To achieve this, the function fits a model for every sequence provided as input, computes its score according to the objective criterion, and finds the sequence that provided the "best" score. Again, choose() will return the sequence, the score, and the model object corresponding to that sequence.          

### Select      

Lastly, the select() function uses the modular functions written earlier and implements the genetic algorithm as follows:           

1. Generate an initial list of p sequences using the function generate(). Since this sequence is a binary encoding representing whether or not to include a covariate in the model, one suggested way to do this is to choose p such that p is between c and 2c, where c is the length of each sequence. We decided to make p equal to two times the ceiling of (1.5*c)/2, which ensures that p is an even number between C and 2C.      

Then, run steps 2-5 until the absolute value of the difference between the objective criterion score of the current iteration and the objective criterion score of the previous iteration is less than .0001 (absolute convergence) or if the algorithm has run for over 100 iterations.     

2. Select p/2 pairs of parents to do genetic operations on using the select() function.     

3. Use crossover() to create a pair of children for each of the p/2 pairs of parents.      

4. Use mutate() to mutate each of the p children sequences.         

5. Fit the models corresponding to each of the p mutated sequences and return the best model along with its objective criterion score using choose().      

6. Once the algorithm converges, return the model with the best objective criterion score from the final iteration of the algorithm, and that will be the model that is selected by the genetic algorithm.     

## Application
Here are three ways one would use the select() function:

```r
library(GA)
```

For the examples below, we will use mtcars, which is a built-in dataset containing 11 variables. Here is how the dataset looks like.

```r
data <- mtcars
head(mtcars)
```

### Example 1     
First, we will run the genetic algorithm for linear regression using all the available variables in the dataset to predict "mpg". 

```r
response <- "mpg"
covariates <- c("cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb")
select(data, response, covariates)
```

### Example 2      
Here, we will use select() to perform logistic regression. Since the variables "vs" takes values 0 or 1, we will perform logistic regression on that variable using the remaining 10 as covariates.

```r
response <- "am"
covariates <- c("mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "gear", "carb")
select(data, response, covariates, family = "binomial")
```


### Example 3         
Here, let's say we don't think the variables "gear" and "carb" are useful for predicting "mpg". In this case, we can provide as input a subset of all the available variables in the dataset as covariates and select() will only run the genetic algorithm on that subset of variables. I will also use BIC as the objective criterion to show that the function can take other objective criterion functions.

```r
response <- "mpg"
covariates <- c("cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am")
select(data, response, covariates, criterion="BIC")
```



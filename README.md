<style TYPE="text/css">
code.has-jax {font: inherit; font-size: 100%; background: inherit; border: inherit;}
</style>
<script type="text/x-mathjax-config">
MathJax.Hub.Config({
tex2jax: {
inlineMath: [['$','$'], ['\\(','\\)']],
skipTags: ['script', 'noscript', 'style', 'textarea', 'pre'] // removed 'code' entry
}
});
MathJax.Hub.Queue(function() {
var all = MathJax.Hub.getAllJax(), i;
for(i = 0; i < all.length; i += 1) {
all[i].SourceElement().parentNode.className += ' has-jax';
}
});
</script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=TeX-AMS_HTML-full"></script>


# Genetic Algorithm for Variable Selection in Regression

This package implements a genetic algorithm for variable selection in regression using the guidelines outlined in [Chapter 3](https://github.com/zihanye96/Genetic_Algorithm/blob/master/givens_hoeting_ch3.pdf) of *Computational Statistics* by Geof H. Givens and Jennifer A. Hoeting. The package includes modular functions that are designed to execute individual steps in the algorithm, and the main function, **select()**, utilizes these modular functions to output the "best" regression model using the inputs provided by the user (more below)  

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

The selection() function takes as input a generation (list) of $p$ sequences and outs $\frac{p}{2}$ pairs of "parents", with each pair being a numeric vector of 2 index values, each corresponding to a sequence in the input. We chose to select one parent with probability proportional to fitness and one parent completely at random, which will reduce the chance of one parent dominating the gene pool at early iterations of the algorithm and cause the algorithm to converge prematurely. We used a rank-based method for selection by ranking each model based on the objective criterion (which is AIC by default) and assigning each model a probability based on rank as follows:
$$\phi(\vartheta_i^{(t)}) = \frac{2r_i}{P(P+1)}$$ 
where $r_i$ is the rank of the sequence based on the objective criterion (higher is better), $P$ is the number of sequences in a generation, and $\phi$ is the probability of being selected as a parent for a given model. For a given iteration number $t$, the $i$th sequence can be chosen as parent 1 with probability $\phi(\vartheta_i^{(t)})$. Parent 2 is chosen completely at random, so each sequence has an equal chance of being selected as parent 2.     

### Crossover     

The crossover() function takes as input a numeric vector of two index values and performs the crossover genetic operator on the 2 "parent" sequences in the generation corresponding to those two index values. Let $c$ be the length of a sequence in this problem. To achieve this, we chose a splitting point to split the sequences. The splitting point will be a value between $1$ and $c-1$, randomly drawn with equal probability. If the value of the splitting point is 2, then the function will split each sequence into two parts, with one part consisting of the sequence up to (and including) the 2nd bit and one part consisting of the sequence after (not including) the second bit. As a result, the function splits each sequence into parts A and B. To generate "child" sequences from the "parent" sequences, the function concatenates part A of sequence 1 with part B of sequence 2 to create the first child and does the same with part A of sequence 2 with part B of sequence 1 to create the second child.     


### Mutate      

The mutate() function takes as input a sequence of length $c$ and mutates each bit in the sequence with probability $\frac{1}{c}$. We chose the mutation rate of $\frac{1}{c}$ because "theoretical work and empirical studies have supported a rate of $1/C$" [Givens and Hoeting, 80]. If after mutating a chromosome, the chromosome contains all 0's, then the function repeats the mutation process until the chromosome doesn't contain all 0's, as it's not possible to fit a model with no covariates.          

### Choose      

The choose() function takes as input a list of mutated sequences and returns the "best" sequence in that generation in terms of objective criterion score, along with its objective criterion score and the model object of the regression model corresponding to that sequence. To achieve this, the function fits a model for every sequence provided as input, computes its score according to the objective criterion, and finds the sequence that provided the "best" score. Again, choose() will return the sequence, the score, and the model object corresponding to that sequence.          

### Select      

Lastly, the select() function uses the modular functions written earlier and implements the genetic algorithm as follows:           

1. Generate an initial list of p sequences using the function generate(). Since this sequence is a binary encoding representing whether or not to include a covariate in the model, one suggested way to do this is to choose p such that $C \leq P \leq 2C$, where c is the length of each sequence [Givens and Hoeting, 79]. We decided to make $P = ceiling(\frac{1.5 \times C}{2}) \times 2$, which ensures that it's an even number between $C$ and $2C$.      

Then, run steps 2-5 until the absolute value of the difference between the objective criterion score of the current iteration and the objective criterion score of the previous iteration is less than $10^{-4}$ (absolute convergence).     

2. Select $\frac{p}{2}$ pairs of parents to do genetic operations on using the select() function.     

3. Use crossover() to create a pair of children for each of then $\frac{p}{2}$ pairs of parents.      

4. Use mutate() to mutate each of the $p$ children sequences.         

5. Fit the models corresponding to each of the $p$ mutated sequences and return the best model along with its objective criterion score using choose().      

6. Once the algorithm converges, return the model with the best objective criterion score from the final iteration of the algorithm, and that will be the model that is selected by the genetic algorithm.     



### Introduction

This document explains the process for reproducing the data and analysis described in the paper entitled ``A Cohort Location Model of Household Sorting in US Metropolitan Regions''.  There are three key steps in reproducing the data and analysis:

1. Download all code and data files from this repository at: [http://www.github.com/AndyKrause/hhLocation](http://www.github.com/AndyKrause/hhLocation "Git")

2. Open the code in R and change the directory paths to your desired paths (more on this later)

3. Execute the **hhLocAnalysis.R** script.  Note:  this may take a few hours as the raw data is downloaded the first time you run the script.

NOTE: Data at two intermediate steps may be downloaded from a Dataverse Repository at: [http://dx.doi.org/10.7910/DVN/C9KPZA](http://dx.doi.org/10.7910/DVN/C9KPZA).  This allows the user to skip the very lengthly and data storage heavy data compilation and initial cleaning and compiling steps (if so desired).  The two intermediate datasets are described below.

### Downloading Code and Data

All code used the create this analysis, including raw data, cleaned data and final analysis are available at [http://www.github.com/AndyKrause/hhLocation](http://www.github.com/AndyKrause/hhLocation "Git").  This complete data provenance is recorded in R (version 3.1.1) and was built using the RStudio IDE.  There are four separate files in this repository.  The first, **hhLocAnalysis.R:**, is the main script and is the only one that needs to be updated and executed.  A description of each is below.

1. **hhLocAnalysis.R:**  The main script which controls the data cleaning, analysis and plotting.
2. **buildCBSAData.R:**  A set of functions to download and prepare the necessary CBSA information.
3. **buildHHData.R:** A set of functions for downloading and preparing the necessary census SF1 data.
4. **hhLocFunctions.R:** A set of functions for analyzing and plotting the household location data and results.

Along with this code files are three small data files in .csv form.  The first is required to run the analysis in any form, while the second two are necessary only to recreate the analysis exactly as first performed.  Note that removing the second and third file but keeping the `nbrCBSA` parameter at a value of **50** will create the same results. 

1. **statelist.csv:**  Simple list of all 50 states with their abbreviations.
2. **studyCBSAlist.csv:**  A list of the 50 most populous CBSAs in the United States.
3. **studyCitylist:** A list of all cities (subcenters) that are named within the most populous 50 CBSAs.

#### Intermediate Data

To save time, the user may download intermediate datasets -- prepared data (predData.csv) and cleaned data (cleanData.csv) from the DATAVERSE site.  The prepared data included compiled household age information on all census blocks in the 50 largest CBSAs.  The cleaned data has removed census blocks without households, fixed a number of city names and rescaled the distances.  Instructions on how to replicate the analysis with either of the intermediate datasets is described below. 

### Before running the code

#### R Libraries

Ensure that the following R libraries are installed: `ggplot2`, `plyr`, `dplyr`, `geosphere` and `stringr`.  You can check them with the `library` commands as shown below.  Missing libraries can be downloaded and installed with `install.packages('ggplot2')`, for example. 

library(ggplot2)
library(reshape)
library(plyr)
library(dplyr)
library(geosphere)
library(stringr)

#### Analysis parameters

Six parameters control the depth and type of analyses that will be performed.  **reBuildData** determines whether or not the user intends to download all of the raw data directly from the census and completely recreate the analysis from scratch.  Users who have NOT downloaded one of the two intermediate datasets must set this parameter to TRUE. **reCleanData** determines whether or not the prepared data will be cleaned. Users who have downloaded the **cleanData.csv** may set this to FALSE and use the downloaded dataset.  The **reScaleDists** parameter allows users to change the scaling of the distance variables.  If the user is recreating the data from the beginning (not using intermediate datasets) then setting **reScaleDists** to FALSE will use all census block groups with households regardless of their distance from the centers or subcenters in the CBSA.  Setting this parameter to TRUE will scale the distances by the lesser of the maximum distance in each CBSA region or by the global **maxDist** parameter (in miles).  In the paper we use a maximum distance of 60 miles.  If the user has opted to use the clean data intermediate dataset then the data is already scaled to the 60 mile distance and this parameter can be set to FALSE.

The **nbrCBSA** parameter determines how many CBSAs to analyze.  The count is done from the most populous down to the least populous.  A value of 50 is used in the analysis described in the paper.  A user wishing to change this value will have to recreate the data from scratch (set **reBuildData**, **reCleanData** and **reScaleDists** to TRUE).  Greatly increasing this value may greatly lengthen run-times and, depending on your computer memory, may crash the analysis. Finally, the **verbose** parameter defines whether or not the data-building and analytical functions will write their progress to the screen.  The defaults for the six parameters used in the paper are shown below. 

reBuildData <- TRUE
reCleanData <- TRUE
reScaleDists <- TRUE
nbrCBSA <- 50
maxDist <- 60
verbose <- TRUE
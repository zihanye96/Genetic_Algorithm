# Genetic Algorithm for Variable Selection in Regression

This package implements a genetic algorithm for variable selection in regression using the guidelines outlined in (Chapter 3)[https://github.com/zihanye96/Genetic_Algorithm/blob/master/givens_hoeting_ch3.pdf] of *Computational Statistics* by Geof H. Givens and Jennifer A. Hoeting. The package includes modular functions that are designed to execute individual steps in the algorithm, and the main function, **select()**, utilizes these modular functions to output the "best" regression model using the inputs provided by the user (more below)  

## Overview

The main function, select(), will take 6 inputs:      

1. The object corresponding to the dataset being used.             

2. A character string corresponding to the name of the response variable the user would like to model.

3. A vector of the character strings of names of the predictor variables (covariates) that the user would like to consider using. This allows the user to directly leave out certain information in the dataset that they don't consider to be useful in prediction.         

4. A character string corresponding to the name of the objective criterion/fitness function that will be used to evaluate each model. By default, the function uses "AIC", but the user can use other objective criterion available in base R (ex. BIC) or write their own fitness function.      

5. A character string corresponding to the type of regression the user would like to perform. By default, the function uses "Gaussian", which is the default identity link that's equivalent to performing standard linear regression. However, the user can specify other families, such as binomial, which uses a logit link by default and allows the user to perform logistic regression. The user can specify any family that is accepted by the glm() function.      

6. A boolean variable called "maximize", indicating whether the objective criterion should be maximized or minimized. For example, if the objective criterion select() is using is written by the user and the user would like to maximize this objective criterion (instead of minimize, as one would if the objective criterion were AIC), they can specify "maximize = TRUE" as an input. By default, maximize is false.     

Using these inputs, select() will run a genetic algorithm and return the regression model at the final iteration of the algorithm.

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
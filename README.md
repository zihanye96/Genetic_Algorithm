
# Genetic Algorithm for Variable Selection in Regression

This package implements a [genetic algorithm](https://github.com/zihanye96/Genetic_Algorithm/blob/master/givens_hoeting_ch3.pdf) for variable selection in regression. The idea is to find a subset of the available features/variables that optimizes an objective criterion (ex. AIC) in regression. This allows the user to get a sense of feature importance while reducing the risk of overfitting by only regressing on the most "important" variables determined by the algorithm. This algorithm is notably more efficient than stepwise regression (e.g. forward selection, backward elimination), especially as the number of available features increases.

The [documentation](documentation.md) discusses the package in more detail.This package was created in collaboration with Asem Berkalieva and Jing Xu at UC Berkeley.  


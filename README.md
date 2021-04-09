# optimization-tec
Optimization models using Julia JuMP for Optimization courses at Tec de Monterrey campus Santa Fe.

___
#### Examples_JuliaJUMP
Constains some example JUMP model with relevant related data files when applicable. 
The most interesting one is perhaps de dateModel that uses a matrix 10,000 x 10,000 of data and variables. This is the type of problem that is not longer managable in Excel.

#### K_means 
Shows how to build clusters using k-means and graph the results.

### Trans-shipmnt Problem
Shows how to optimize connections between serial nodes minimizing cost function in the travel between nodes. Ensuring a certain amount of inputs produces in the starting node reach the final destination.

#### Traveling_Salesman
Shows two approaches to solving the TSP problem. One that ensures finding the optimal solution using the MTZ formulation. And a 2nd heuristic method based on a genetic algorithm that finds a possible solution to a large node problem in a much faster time. Can be run many times to try ro find alternate results.


The code and functions in this repo include some of the following functionalities for Julia:

* Formulating and solving optimization problem with JuMP.
* Importing Excel data.
* Transforming data and converting to matrices
* Graphing solutions
* Writing formatted outputs to terminal.

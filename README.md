# ConstrainedFalsification 
 
"Hybrid System Falsification Under (In)equality Constraints via Search Space Transformation", EMSOFT 2020

***

## System requirement

- Operating system: Linux or MacOS;

- Matlab (Simulink/Stateflow) version: >= 2020a. (Matlab license needed)

- Python version: >= 3.3

## Installation

- Clone the repository.
  1. `git clone https://github.com/choshina/ConstrainedFalsification.git`
  2. `git submodule init`
  3. `git submodule update`

- Install [Breach](https://github.com/decyphir/breach).
  1. start matlab, set up a C/C++ compiler using the command `mex -setup`. (Refer to [here](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html) for more details.)
  2. navigate to `breach/` in Matlab commandline, and run `InstallBreach`


 ## Usage

We use the example of Section V.A Fixed priority (called "single" in our code) to explain how to run the code.

 - The user-specified configuration files are stored in the directory `test/config/`. Replace the paths in the line `addpath 1` with their own paths. Users can also specify other configurations, such as model, input ranges, optimization methods, etc. 
 - Navigate to the directory `test/`. Run the command `python3 prop_single.py config/[user-specified configuration file]`.
   > E.g., `python3 prop_single.py config/single/AT/at_con123_2.config`
 - Now the executable scripts have been generated under the directory `test/benchmarks/`. Users need to edit the executable scripts permission using the command `chmod -R 777 *`.
 - Navigate to the project home, and run the command `make`. The automatically generated .csv experimental results will be stored in directory `results/`, and the corresponding log will be stored under directory `output/`.
   > This will run all the scripts generated under `test/benchmarks/`. To reduce the files and reduce the experimental repetitions, modify the configuration files as below. 

## Configuration files
 - cons are about input constraints, which are stored in `src/constr/`
 - S specifies the priority
 - currently, if we specify multiple specifications, multiple constraints, multiple priorities, there will be all the combinations of these configurations generated in `test/benchmarks/`. To simplify it, just modify the configurations files. Users can also reduce `trials` to reduce the number of experiment repetitions.



# ConstrainedFalsification 
 
"Hybrid System Falsification Under (In)equality Constraints via Search Space Transformation", EMSOFT 2020

***

## System requirement

- Operating system: Linux or MacOS;

- Matlab (Simulink/Stateflow) version: >= 2020a. (Matlab license needed)

- Python version: >= 3.3

## Installation

- Clone the repository.
  1. `git clone https://github.com/choshina/ForeSee.git`
  2. `git submodule init`
  3. `git submodule update`

- Install [Breach](https://github.com/decyphir/breach).
  1. start matlab, set up a C/C++ compiler using the command `mex -setup`. (Refer to [here](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html) for more details.)
  2. navigate to `breach/` in Matlab commandline, and run `InstallBreach`

- Install our tool ForeSee.
  1. in terminal navigate to ForeSee home, and run `sh InstallForeSee.sh`

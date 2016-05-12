# R-BI-BBOB
Unofficial R bindings for [BI-BBOB COCO platofrm](https://github.com/numbbo/coco) based on [R.matlab package](https://cran.r-project.org/web/packages/R.matlab/index.html).


# Dependencies

You need the following R packages pre-installed:

* GPareto
* pracma
* R.matlab


# Files Description
1. `experiment_R.R` : the R wrapper allowing you to test the 4 EGO algorithms from `GPareto R package` / Just like the `exampleexperiment.m` in the [BI-BBOB COCO platofrm](https://github.com/numbbo/coco). 
2. `InputStreamByteWrapper.class`: necessary for data communication, taken form the `R.matlab` package.
3. `MatlabServer.m`: handles the communication from MATLAB's side, taken form the `R.matlab` package.


# Running an experiments: 
You need to put the above files in the build/matlab directory of the [COCO platofrm](https://github.com/numbbo/coco). Then fire the following
```
>> Rscript experiment_R.R
```

# Citation

If you write a scientific paper describing research that made use of this code, you may cite the following paper:
```
@InProceedings{AlDu16:GECCO,
  Title                    = {A MATLAB Toolbox for Surrogate-Assisted Multi-Objective Optimization: A Preliminary Study},
  Author                   = {Abdullah Al-Dujaili and Suresh Sundaram},
  Booktitle                = {Genetic and Evolutionary
Computation Conference ({GECCO})},
  Year                     = {2016},
  Address                  = {Denver, USA},
  Month                    = July
}
```

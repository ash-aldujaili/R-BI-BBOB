##########################################
# AN R-WRAPPER FOR THE COCO PLATFORM,2016
# 
# The current experiment settings benchmark 4
# algorithms from the GPareto package
# you can test any other algorithm, by changing 
# the optimizer call and its settings 
# (i.e., modify the 2 if(j=1){}.. statements)
# 
# Copyright (c) 2016 by Abdullah Al-Dujaili
# 
# Some rights reserved. 
# 
# ### 3-clause BSD License ###
# 
# Redistribution and use in source and binary forms of the software as well
# as documentation, with or without modification, are permitted provided
# that the following conditions are met:
#   
#   1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided
# with the distribution.
# 
# 3. The names of the contributors may not be used to endorse or
# promote products derived from this software without specific
# prior written permission.
# 
# THIS SOFTWARE AND DOCUMENTATION IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
# NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#                                      PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#                                      PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#                                                            NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE AND DOCUMENTATION, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
#########################################
#--------------------------
# 1. Load necessary packages:
#--------------------------
library(R.matlab) # interface
library(GPareto) # benchmarking algorithms
library(pracma)
#--------------------------
# 2. Start Matlab
#--------------------------
Matlab$startServer()
matlab <- Matlab()
setVerbose(matlab, 1)
isOpen <- open(matlab)

#-------------------------
# 3. Set the BBOB benchmark
#-------------------------
for (j in 1:1){
  #===================================================================================
  # PUT YOUR ALGORITHM SETTINGS HERE
  #===================================================================================
	if (j == 1) {
		evaluate(matlab,"observer_options = strcat('result_folder: EHI-EGO', ' algorithm_name: EHI-EGO', ' algorithm_info: EHI-EGO');")
	}else if (j == 2) {
		evaluate(matlab,"observer_options = strcat('result_folder: SMS-EGO', ' algorithm_name: SMS-EGO', ' algorithm_info: SMS-EGO');")
	} else if (j == 3) {
		evaluate(matlab,"observer_options = strcat('result_folder: EMI-EGO', ' algorithm_name: EMI-EGO', ' algorithm_info: EMI-EGO');")
	} else {
		evaluate(matlab,"observer_options = strcat('result_folder: SUR-EGO', ' algorithm_name: SUR-EGO', ' algorithm_info: SUR-EGO');")
	}
	evaluate(matlab,"suite = cocoCall('cocoSuite', 'bbob-biobj', 'year: 2016', 'dimensions: 2');")
	evaluate(matlab,"observer = cocoCall('cocoObserver', 'bbob-biobj', observer_options);")
	evaluate(matlab,"cocoCall('cocoSetLogLevel', 'info');")

	BUDGET_MULTIPLIER <- 2; # algorithm runs for BUDGET_MULTIPLIER*dimension funevals
	NUM_OF_INDEPENDENT_RESTARTS <- 0; # max. number of independent algorithm

	# keep track of problem dimension and #funevals to print timing information:
	printeddim <- 1;
	doneEvalsAfter <- 0; # summed function evaluations for a single problem
	doneEvalsTotal <- 0; # summed function evaluations per dimension
	printstring <- '\n'; # store strings to be printed until experiment is finished

	#-------------------------
	# 4. Start
	#-------------------------
	# Here is a loop where you run on the problems one by one till you break
	set.seed(25468)
	while(1 == 1) {
		evaluate(matlab,"problem = cocoCall('cocoSuiteGetNextProblem', suite, observer);")
		# check for valid problem to break
		evaluate(matlab,"isNotValid = ~cocoCall('cocoProblemIsValid', problem);")
		isNotValid <- getVariable(matlab, c("isNotValid"))$isNotValid
		if (isNotValid > 0) {
			break;
		}
		# get the problem dimension
		evaluate(matlab,"dimension = cocoCall('cocoProblemGetDimension', problem);")
		dimension <- getVariable(matlab, "dimension")$dimension
		
		
		# printing
		if (printeddim < dimension){
		  if (printeddim > 1){
			end.time <- Sys.time()
			elapsedtime <- end.time - start.time
			printstring = strcat(printstring, sprintf('COCO TIMING: dimension %d finished in %e seconds/evaluation\n',printeddim, elapsedtime/as.numeric(doneEvalsTotal)));
			print(printstring)
			start.time <- Sys.time()
		  }
		  doneEvalsTotal <- 0;
		  printeddim <- dimension;
		  start.time <- Sys.time()
		} 
		
		evaluate(matlab, "nEvals = cocoCall('cocoProblemGetEvaluations', problem);")
		nEvals <- getVariable(matlab,"nEvals")$nEvals
		i <- -1; # count number of independent restarts
		while (BUDGET_MULTIPLIER*dimension > nEvals) {
			# increment restarts:
        		i <- i+1
        		if (i > 0) {
            		print('INFO: algorithm restarted');
			}
			doneEvalsBefore <- nEvals

		
			#-----------------
			# Optimizer call:
			#----------------
			# a . set optimizer-related info
			n_var <- dimension
			fname <- function(x){setVariable(matlab, x=x); evaluate(matlab, "yvector=cocoCall('cocoEvaluateFunction', problem, x);"); as.numeric(getVariable(matlab,"yvector")$yvector);}
			evaluate(matlab,"lower = cocoCall('cocoProblemGetSmallestValuesOfInterest', problem);")
			evaluate(matlab,"upper = cocoCall('cocoProblemGetLargestValuesOfInterest', problem);")
			lower <- as.numeric(getVariable(matlab,"lower")$lower)
			upper <- as.numeric(getVariable(matlab,"upper")$upper)
			# b . run
			#===================================================================================
      # put your optimizer call here
			#===================================================================================
			if (j == 1) {
				res <- easyGParetoptim(fn=fname, lower=lower, upper=upper, budget=BUDGET_MULTIPLIER*dimension,
				control=list(method="EHI", inneroptim="pso", maxit=10))	
			}else if (j == 2) {
				res <- easyGParetoptim(fn=fname, lower=lower, upper=upper, budget=BUDGET_MULTIPLIER*dimension,
				control=list(method="SMS", inneroptim="pso", maxit=10))	
			} else if (j == 3) {
				res <- easyGParetoptim(fn=fname, lower=lower, upper=upper, budget=BUDGET_MULTIPLIER*dimension,
				control=list(method="EMI", inneroptim="pso", maxit=10))	
			} else {
				res <- easyGParetoptim(fn=fname, lower=lower, upper=upper, budget=BUDGET_MULTIPLIER*dimension,
				control=list(method="SUR", inneroptim="pso", maxit=10))	
			}		
      #===================================================================================
			# get the number of evaluations:
			evaluate(matlab, "nEvals = cocoCall('cocoProblemGetEvaluations', problem);")
			doneEvalsAfter <- getVariable(matlab,"nEvals")$nEvals

			# check necessary breaks:
      # update the number of evaluations:
			nEvals <- doneEvalsAfter
			doneEvalsTotal <- doneEvalsTotal + nEvals
      print(doneEvalsAfter)  
      
			evaluate(matlab,"isFinalTarget = cocoCall('cocoProblemFinalTargetHit', problem) == 1;")
			isFinalTarget <- getVariable(matlab,"isFinalTarget")
			# break.1
			if ((isFinalTarget == 1) || (doneEvalsAfter >= BUDGET_MULTIPLIER * dimension)) {
			  print("Target met / Budget has  been exhausted");
				break;
			}
			# break.2
     if (doneEvalsAfter == doneEvalsBefore) {
				#('WARNING: Budget has not been exhausted (%d/%d evaluations done)!\n', doneEvalsBefore, BUDGET_MULTIPLIER * dimension);
				print("WARNING:Budget has not been exhausted");
            		break;
			}
			# break.3
      if (doneEvalsAfter < doneEvalsBefore){
             		print('ERROR: Something weird happened here which should not happen: f-evaluations decreased');
      }
			# break.4
      if (i >= NUM_OF_INDEPENDENT_RESTARTS){
            		break;
			}
		}

	}

	end.time <- Sys.time()
	elapsedtime <- end.time - start.time
	printstring = strcat(printstring, sprintf('COCO TIMING: dimension %d finished in %e seconds/evaluation\n',printeddim, elapsedtime/as.numeric(doneEvalsTotal)));
	print(printstring)
	#----------------------
	# 5. Clean up
	#----------------------
	evaluate(matlab,"cocoCall('cocoObserverFree', observer);")
	evaluate(matlab,"cocoCall('cocoSuiteFree', suite);")
}
close(matlab)
 

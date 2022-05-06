# Climate warming amplifies the frequency of fish mass mortality events across north temperate lakes

This is the public repository for the "Climate warming amplifies the frequency of fish mass mortality events across north temperate lakes" in Limnology Oceanography Letters. The code is split into 7 RMarkdown files that perform different steps of the project. If you have any problems running the code, please contact me at simontye@uark.edu and I will help as best I can.

## 01_combine_datasets.Rmd
Combine MN and WI fishkill datasets with thermal estimates. After running this script, the historical (2003-2014) and future (2041-2059; 2081-2099) dataframes are compiled as `df_historical.csv` and `df_future.csv`, respectively.

## 02_prepare_models.Rmd
Partition data into training and testing sets.
	
## 03_fit_models.Rmd
Compare preliminary models from 3 model families:

1. Logistic regression
2. Ridge regression
3. Lasso regression

## 04_assess_models.Rmd

Compare preliminary models.

## 05_fit_full_models.Rmd

Run best fit models.

## 06_statistics.Rmd

Perform statistics.

## 07_figures.Rmd

Create figures.
```
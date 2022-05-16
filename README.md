# Climate warming amplifies the frequency of fish mass mortality events across north temperate lakes

This is the public repository for "Climate warming amplifies the frequency of fish mass mortality events across north temperate lakes" in Limnology Oceanography Letters. The R code is partitioned into 7 RMarkdown files that perform discrete steps (e.g., compile data, run models, create figures).

All data files necessary to perform analyses are available as releases associated with this project. There are 7 releases that each contain discrete groups of files that are under the 2 GB file size limit for releases (e.g., raw data, processed data, models).

If you have any problems running the code, please contact me at simontye@uark.edu and I will help as best I can. Below are brief descriptions of each RMarkdown file.

## 01_combine_datasets.Rmd
Combines Minnesota and Wisconsin fishkill datasets, then collates local environmental covariates. After running this script, the historical (2003-2013) and future (2041-2059; 2081-2099) dataframes are saved as `df_historical.csv` and `df_future.csv`, respectively.

## 02_prepare_models.Rmd
Partitions data into training and testing sets.
	
## 03_fit_models.Rmd
Compares preliminary models from 3 model families:

1. Logistic regression
2. Ridge regression
3. Lasso regression

## 04_assess_models.Rmd

Compares preliminary models.

## 05_fit_full_models.Rmd

Runs best fit models.

## 06_statistics.Rmd

Performs statistics.

## 07_figures.Rmd

Creates figures.
```
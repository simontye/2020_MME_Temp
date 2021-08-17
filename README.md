# Fish mortalities accentuated by warming temperatures across north temperate lakes

The code is finished, and there are some figures in the `figures` folder. Only the code is on GitHub because it is too cumbersome to upload the files (~38 GB). All files, including this code, is on the Midwest MME Google Drive folder maintained by Sam.

https://drive.google.com/drive/folders/1t64Sopf__xee70lAIRQXr0ORG4-1xym6

## 01_combine_datasets.Rmd
This combines MN and WI fishkill datasets with thermal estimates. After running this script, the historical (2003-2014) and future (2041-2059; 2081-2099) dataframes are compiled as `df_historical.csv` and `df_future.csv`, respectively. The markdown file is organized into the following steps:

1.  Load packages and data.
2.  Add Minnesota fishkill data
3.  Add Wisconsin fishkill data
4.  Format final fishkill dataset
5.  Preliminary map of fishkills
6.  Add historical water temperature data
7a. Add historical air temperature data (NOAA)
7b. Add historical air temperature data (PRISM)
8.  Add geographic and census data
9.  Add future water temperature data
13. Add future air temperature data
14. Add snowfall data

## 02_prepare_models.Rmd
1. Partition data into training and testing sets
2. Scale data in training sets
3. Exports training and testing sets
	a. `models/training.csv`: Training set
	a. `models/testing.csv`: Testing set
	
## 03_fit_models.Rmd
Compares preliminary models from three model families:

1. Logistic regression
2. Ridge regression
3. Lasso regression

## 04_assess_models.Rmd

Compares preliminary models.

## 05_fit_full_models.Rmd

Runs the best fit models based on assessments.

## 06_statistics.Rmd

Statistics.

## 07_figures.Rmd

Figures. I will break those down into seperate R files if necessary.
```
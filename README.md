# Hot air or warm water: fishkills in north temperate lakes

### Authors
Mass mortality crew

### Workflow
The code to replicate this study are located in the following R Markdown files.

1. `01_combine_datasets.Rmd`: Combines MN and WI fishkill datasets with air and water temperature data.
2. `02_prepare_models.Rmd`: Partitions and scales the combined dataset.
3. `03_fit_models.Rmd`: In progress

### 01_combine_datasets.Rmd
This code combines four datasets: MN fishkill data, WI fishkill data, water temperature data, and air temperature data from the nearest NOAA station).
1. Organizes MN fishkill data from Phelps et al. (2019)
2. Matches GPS coordinates of fishkill events with the centroid of the nearest waterbody. 
2. Organizes WI fishkill data from Till et al. (2019)
3. Merges the fishkill datasets
4. Groups fish taxa by family
5. Creates a preliminary map to show fishkill localities
6. Merges fishkill dataset with water temperature data from Winslow et al. (2017)
7. Matches GPS coordinates of NOAA weather stations with the centroid of the nearest waterbody.
8. Merges fishkill dataset with local air temperature data.
9. Adds spatial data for each waterbody.
10. Exports final datasets.
	a. `processed/model_data_annual.csv`: Annual dataset
	b. `processed/model_data_monthly.csv`: Monthly dataset

### 02_prepare_models.Rmd
This code is from the Till et al. (2019) workflow, and creates a training and testing sets for modeling.
I need to verify and clean up the final datasets from 01_combine_datasets.Rmd before this runs properly.

1. Partition data into training and testing sets
2. Scale data in training sets
3. Exports training and testing sets
	a. `models/training.csv`: Training set
	a. `models/testing.csv`: Testing set
	
### 03_fit_models.Rmd
In progress

### Data
All data files are categorized as either raw, processed, or model. These data are available for download via GitHub or R.
For GitHub, click "Release" in the top menu and then download "data_1.0.zip".
For R, run the following chunk of code.

```{R: Download data files}
# install.packages("piggyback")
# require(piggyback)
# pb_download(repo = "simontye/2020_MME_Temp" 
#             tag  = "1.0",
#             dest = "data")
```
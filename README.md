# Hot air or warm water: fishkills in north temperate lakes

### Authors
Mass mortality crew

### Workflow
The code to replicate this study are located in the following R Markdown files.

1. `01_combine_datasets.Rmd`: Combines MN and WI fishkill datasets with air and water temperature data.
2. `02_prepare_models.Rmd`: Partitions and scales the combined dataset.
3. `03_fit_models.Rmd`: In progress

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
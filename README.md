# Shiny App for Consistency check for age-dependent reference intervals!

<img src="www/Logo.svg" width="225px" height="150px" align="right"/>

This Shiny App computes the zlog values of the preceding and the subsequent reference interval for different analytes for each age group, see the [Wiki](https://github.com/SandraKla/Zlog_AdRI/wiki). 

Many medical reference intervals are hardly age-dependent and have large jumps between the individual age groups. This should be prevented by considering the zlog value. If the zlog value deviates significantly from -1.96 to 1.96, the reference intervals and the age groups should possibly be renewed to obtain age-dependent reference intervals!

<img src="docs/shiny.png" align="center"/>

## Installation 

Download the Zip-File from this Shiny App and set your working direction to this path and run:

```bash
# Test if shiny is installed:
if("shiny" %in% rownames(installed.packages())){
  library(shiny)} else{
  install.packages("shiny")}
```

```bash
library(shiny)
runApp("app.R")
```
Or use the function ```runGitHub()``` from the package *shiny*:

```bash
library(shiny)
runGitHub("Zlog_AdRI", "SandraKla")
```

The package "DT" is downloaded or imported when starting this app. For more information about the required versions use the [Wiki](https://github.com/SandraKla/Zlog_AdRI/wiki).

### Example

The [CALIPER](https://caliper.research.sickkids.ca/#/) dataset with age-dependent reference intervals has been implemented into this Shiny App. For this purpose, the data was brought into the appropriate shape for the analysis from the table [Supplemental Table 2](https://academic.oup.com/clinchem/article/58/5/854/5620695#supplementary-data) from Age-Specific and Sex-Specific Pediatric Reference Intervals for 40 Biochemical Markers. For new data use the CALIPER-Dataset as [template](https://github.com/SandraKla/Zlog_AdRI/blob/master/data/CALIPER.csv) with the columns:

* **CODE**: Name of the analyte ("Calcium") 
* **LABUNIT**: Unit of the analyte ("mmol/L")
* **SEX**: "M" for male and "F" for female
* **UNIT**: Unit of the age range in "year", "month", "week" or "day"
* **AgeFrom**: Start of the age range 
* **AgeUntil**: End of the age range 
* **LowerLimit**: Start of the reference interval (LL)
* **UpperLimit** Start of the reference interval (UL)
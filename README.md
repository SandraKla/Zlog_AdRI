# Shiny App for Plausibility Checks of Reference Interval Limits!

<img src="www/Logo.svg" width="225px" height="150px" align="right"/>

[![](https://img.shields.io/github/license/SandraKla/Zlog_AdRI.svg)]()
[![](https://img.shields.io/github/last-commit/SandraKla/Zlog_AdRI/master.svg)]()
[![](https://img.shields.io/github/languages/count/SandraKla/Zlog_AdRI.svg)]()
[![](https://img.shields.io/github/languages/top/SandraKla/Zlog_AdRI.svg)]()

This Shiny App computes the zlog values of the preceding and the subsequent reference interval for different analytes for each age group. Many medical reference intervals are not age-dependent and have large jumps between the individual age groups. This should be prevented by considering the zlog value. The lower reference limits (LL) and upper reference limits (UL) can transform any result x into a zlog value using the following equation: 


<img src="https://render.githubusercontent.com/render/math?math={zlog(x)=(log(x) - \frac{log(UG) %2B log(OG)}{2}}) * \frac{3.92}{log(OG) - log(UG)}" align="center">
If the zlog value deviates significantly from -1.96 to 1.96, the reference intervals and the age groups should possibly be renewed to obtain age-dependent reference intervals.
<p>&nbsp</p>
<img src="docs/table.png" align="center"/>
<img src="docs/shiny.png" align="center"/>

## Installation 

**Method 1:**
Use the function ```runGitHub()``` from the package [shiny](https://cran.r-project.org/web/packages/shiny/index.html):

```bash
if("shiny" %in% rownames(installed.packages())){
  library(shiny)} else{install.packages("shiny")}
runGitHub("Zlog_AdRI", "SandraKla")
```

**Method 2** (not recommended):
Download the Zip-File from this Shiny App. Unzip the file and set your working direction to the path of the folder. 
The package [shiny](https://cran.r-project.org/web/packages/shiny/index.html) (≥ 1.7.1) must be installed before using the Shiny App:

```bash
# Test if shiny is installed:
if("shiny" %in% rownames(installed.packages())){
  library(shiny)} else{install.packages("shiny")}
```
And then start the app with the following code:
```bash
runApp("app.R")
```

The package [DT](https://cran.r-project.org/web/packages/DT/index.html) (≥ 0.21) is downloaded or imported when starting this app. The used [R](https://www.r-project.org)-Version must be ≥ 4.1.2 (2021-11-01) -- "Bird Hippie".

## Usage

### Preloaded dataset
Data from the [CALIPER-Database](https://caliper.research.sickkids.ca/#/) with age-dependent reference intervals has been preloaded into this Shiny App. For this purpose, the data were brought into the appropriate shape for the analysis from the [Supplemental Table 2](https://academic.oup.com/clinchem/article/58/5/854/5620695#supplementary-data) from the publication: *Closing the Gaps in Pediatric Laboratory Reference Intervals: A CALIPER Database of 40 Biochemical Markers in a Healthy and Multiethnic Population of Children*. 

### New data
For new data use the [CALIPER-Dataset](https://github.com/SandraKla/Zlog_AdRI/blob/master/data/CALIPER.csv) as template with the columns: 

* **CODE**: Name of the analyte ("Calcium") 
* **LABUNIT**: Unit of the analyte ("mmol/L")
* **SEX**: "M" for male, "F" for female and "AL" for male and female together
* **UNIT**: Unit of the age range in "year", "month", "week" or "day"
* **AgeFrom**: Start of the age range 
* **AgeUntil**: End of the age range 
* **LowerLimit**: Start of the reference interval (LL)
* **UpperLimit**: Start of the reference interval (UL)

## Contact

You are welcome to:
- Submit suggestions and Bugs at: https://github.com/SandraKla/Zlog_AdRI/issues
- Make a pull request on: https://github.com/SandraKla/Zlog_AdRI/pulls
- Write an Email with any questions and problems to: s.klawitter@ostfalia.de

For more information use the [Homepage](https://sandrakla.github.io/Zlog_AdRI/)! 

Link to the publication: *A Tool for Plausibility Checks of Reference Interval Limits*

See also the CRAN-package "zlog": Sebastian Gibb. (2021). ampel-leipzig/zlog: First public CRAN release. (1.0.0). Zenodo. [10.5281/zenodo.4732319](https://doi.org/10.5281/zenodo.4732319)

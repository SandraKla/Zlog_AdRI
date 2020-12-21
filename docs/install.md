* [Home](./index.md)
* [Installation](./install.md)
* [Guide](./guide.md)
* [About](./about.md)

---

## Installation 

**Method 1:**
Download the Zip-File this Shiny App. Unzip the file and set your working direction to the path of the folder. 
The package [shiny](https://cran.r-project.org/web/packages/shiny/index.html) (≥ 1.4.0) must be installed before using the Shiny App:

```bash
# Test if shiny is installed:
if("shiny" %in% rownames(installed.packages())){
  library(shiny)} 
else{
  install.packages("shiny")}
```
And then start the app with the following code:
```bash
runApp("app.R")

In RStudio with installed [shiny](https://cran.r-project.org/web/packages/shiny/index.html) use the Run App-Button:

<p float="left">
  <img src="shiny_button.png" align="center" style="width:300px;"/>
</p>

```
**Method 2:**
Use the function ```runGitHub()``` from the package [shiny](https://cran.r-project.org/web/packages/shiny/index.html):

```bash
library(shiny)
runGitHub("Zlog_AdRI", "SandraKla")
```

The package [DT](https://cran.r-project.org/web/packages/DT/index.html) is downloaded or imported when starting this app. For more information about the required packages, see [About](./about.md).

## CALIPER-Dataset

The [CALIPER](https://caliper.research.sickkids.ca/#/)-Dataset with age-dependent reference intervals has been preloaded into this Shiny App. For this purpose, the data was brought into the appropriate shape for the analysis from the [Supplemental Table](https://academic.oup.com/clinchem/article/58/5/854/5620695#supplementary-data) from the publication: *Age-Specific and Sex-Specific Pediatric Reference Intervals for 40 Biochemical Markers*. 
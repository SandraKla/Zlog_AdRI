* [Home](./index.md)
* [Installation](./install.md)
* [Guide](./guide.md)
* [About](./about.md)

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
```
**Method 2:**
Use the function ```runGitHub()``` from the package [shiny](https://cran.r-project.org/web/packages/shiny/index.html):

```bash
library(shiny)
runGitHub("Zlog_AdRI", "SandraKla")
```

The package *DT* is downloaded or imported when starting this app. For more information about the required packages, see [About](./about.md).

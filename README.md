# Zlog_AdRI

<img src="Logo.svg" width="225px" height="150px" align="right"/>

**Shiny App for show Zlog value**

This Shiny App computes for each age group the zlog values of the preceding and the subsequent age group for different analytes, see the [Wiki (https://github.com/SandraKla/Zlog_AdRI/wiki). 

<img src="shiny.png" align="center"/>

## Installation

Download the Zip-File from this Shiny App and set the working direction to the order and run:

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

All required packages are downloaded when starting this app or read in if they already exist, see also the [Wiki](https://github.com/SandraKla/Zlog_AdRI/wiki) for the required packages.

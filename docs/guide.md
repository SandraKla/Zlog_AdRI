# **Shiny App for Consistency check for age-dependent reference intervals!**

* [Home](./index.md)
* [Installation](./install.md)
* [Guide](./guide.md)
* [About](./about.md)

## CALIPER-Dataset

The [CALIPER](https://caliper.research.sickkids.ca/#/) dataset with age-dependent reference intervals has been loaded into this Shiny App. For this purpose, the data was brought into the appropriate shape for the analysis from the table [Supplemental Table 2](https://academic.oup.com/clinchem/article/58/5/854/5620695#supplementary-data) from Age-Specific and Sex-Specific Pediatric Reference Intervals for 40 Biochemical Markers.

## Load new data 

For new data use the [template](https://github.com/SandraKla/Zlog_AdRI/blob/master/data/CALIPER.csv) with the columns: **CODE** (name of the analyte); **CODE2** (details of the analyte); **LABUNIT** (unit of the analyte); **SEX**; **UNIT** (unit of the age range in year/month/week/day); **AgeFrom** and **AgeUntil** (age range); **LowerLimit** and **UpperLimit** (reference intervals).

<img src="data_format.png" align="center"/>

## Guide
### Step 1: Settings

If the lower reference limit is zero, it will be set to 0.001 (in the table in red) and the upper reference limit to 100 (in the table in blue) or by the given reference limits!

<img src="settings.png" align="center"/>

### Step 2: Table

With the help of the table, find high zlog values and the appropriate laboratory parameters. These can be visualized in step 3.

<img src="table.png" align="center"/>

### Step 3: Plot 

This Shiny App computes for each lab parameter and each age group the zlog values of the preceding and the subsequent age group. This is the left plot. The zlog value should be optimally in the middle of the green lines between 1.96 and -1.96. Zlog values above 4 or -4 should be checked and minimized by adding an additional age group with new calculated reference intervals. The right plot shows the current used reference intervals. The upper reference limit is in red and the lower limit in blue. 

Legend:
■ Zlog to the preceding age group
• Zlog to the subsequent age group
▲ stands for the reference intervals

<img src="shiny.png" align="center"/>
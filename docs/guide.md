* [Home](./index.md)
* [Installation](./install.md)
* [Guide](./guide.md)
* [About](./about.md)

## CALIPER-Dataset

The [CALIPER](https://caliper.research.sickkids.ca/#/)-Dataset with age-dependent reference intervals has been preloaded into this Shiny App. For this purpose, the data was brought into the appropriate shape for the analysis from the [Supplemental Table](https://academic.oup.com/clinchem/article/58/5/854/5620695#supplementary-data) from the publication: *Age-Specific and Sex-Specific Pediatric Reference Intervals for 40 Biochemical Markers*. 

## Guide
### Load new data 

For new data use the CALIPER-Dataset(https://github.com/SandraKla/Zlog_AdRI/blob/master/data/CALIPER.csv) as template with the columns:

* **CODE**: Name of the analyte ("Calcium") 
* **LABUNIT**: Unit of the analyte ("mmol/L")
* **SEX**: "M" for male and "F" for female
* **UNIT**: Unit of the age range in "year", "month", "week" or "day"
* **AgeFrom**: Start of the age range 
* **AgeUntil**: End of the age range 
* **LowerLimit**: Start of the reference interval (LL)
* **UpperLimit**: Start of the reference interval (UL)

The data must be in CSV-format.

<img src="data_format.png" align="center"/>

### Settings

<p float="left">
  <img src="setting.png" align="center" style="width:300px;"/>
</p>

1.	Upload the CSV File with own reference intervals 
2.	Replacement values: If the lower reference limit is zero, it will be set to 0.001 and the upper reference limit to 100 or by own given reference limits.
3.	Select the sex
4.	Select the lab parameter
5.	Select the logarithmic scale for the x-axis
6.	Select the maximum zlog value for quick determination of very high zlog values
7.	Download the data with the zlog values

### Table with zlog values

With the help of the table, find high zlog values and the appropriate laboratory parameters. These can be visualized in step 3. The table shows the zlog values. Zlog values under -1.96 in blue and above 1.96 in orange. The zlog value should be optimally between 1.96 and -1.96 in white.

<img src="table.png" align="center"/>

### Plot with zlog values 

This Shiny App computes for each lab parameter and each age group the zlog values of the preceding and the subsequent age group. This shows the left plot. The zlog value should be optimally in the middle of the green lines between 1.96 and -1.96. Zlog values above 4 or -4 should be checked and minimized by adding an additional age group with new calculated reference intervals. The right plot shows the current used reference intervals. The upper reference limit is in red and the lower limit in blue. 

<img src="shiny.png" align="center"/>

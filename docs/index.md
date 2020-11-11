# **Shiny App for Consistency check for age-dependent reference intervals!**

* [Home](./index.md)
* [Installation](./install.md)
* [Guide](./guide.md)
* [About](./about.md)

Many medical reference intervals are hardly age-dependent and have large jumps between the age groups. Extreme jumps of reference intervals occur especially for various analytes for newborns, babies or young children. This Shiny App computes the zlog values of the preceding and the subsequent reference interval for different analytes for each age group. This makes it possible to detect strong jumps between two age groups.

The lower reference limits (LL) and upper reference limits (UL) can transform any result x into a zlog value using the following equation: 

<img src="https://render.githubusercontent.com/render/math?math={zlog=(log(x) - \frac{log(UG) %2B log(OG)}{2}}) * \frac{3.92}{log(OG) - log(UG)}" align="center">

If the zlog value of an age groups deviates significantly from -1.96 to 1.96, the reference intervals should possibly be renewed to obtain age-dependent reference intervals. 

<img src="shiny.png" align="center"/>
###################################################################################################
######################### Script to compute the zlog value ########################################
###################################################################################################

#' Computes the zlog value of x given the lower und upper reference limits L and U
#'
#' @param x value
#' @param L lower reference limit
#' @param U upper reference limit
zlog <- function(x,L=0,U=0){
  if (is.na(x) | L<=0 | U<=0 | U<=L){
    return(NA)
  }
  
  logl <- log(L)
  logu <- log(U)
  mu.log <- (logl+logu)/2
  sigma.log <- (logu - logl)/(3.919928)
  
  return((log(x)-mu.log)/sigma.log)
}


#' Computes the age in days given the time unit and the age in the corresponding time unit
#'
#' @param t.unit The specified time unit as a string. 
#' The value of t.unit can be day, week, month or year and 
#' the corresponding German terms Tag, Woche, Monat and Jahr.
#' @param n age
compute.age <- function(t.unit,n){
  if (t.unit=="Tag" | t.unit=="day"){
    return(n)
  }
  if (t.unit=="Woche" | t.unit=="week"){
    return(7*n)
  }
  if (t.unit=="Monat" | t.unit=="month"){
    return(30*n)
  }
  if (t.unit=="Jahr" | t.unit=="year"){
    return(365*n)
  }
}


#' Reorders a table so that for each lab parameter the age groups are ordered in increasing order. 
#' The same but reordered data set. The lab parameters remain in the same order. 
#' But within each lab parameter the order will be increasing in terms of the age groups.
#'
#' @param dats Data frame that must contain at least the columns:
#' CODE, LABUNIT, SEX, UNIT, AgeFrom, AgeUntil, LowerLimit and UpperLimit
sort.age.groups <- function(dats){
  dats.new <- dats
  levs <- levels(factor(dats$CODE))
  for (lev in levs){
    inds <- subset(1:nrow(dats),dats$CODE==lev)
    if (length(inds)>1){
      tps <- rep(0,length(inds))
      for (i in 1:length(tps)){
        tps[i] <- compute.age(dats$UNIT[inds[i]],dats$AgeFrom[inds[i]])
      }
      ord <- order(tps)
      for (i in 1:length(tps)){
        dats.new[inds[i],] <- dats[inds[ord[i]],]
      }
    }
  }
  return(dats.new)
}


#' Computes for each lab parameter and each age group the zlog values of the preceding and the subsequent age group.
#' 
#' The same data frame with the following six additional columns appended at the end.
#' start.time.d     The age in days at which the age group starts.
#' prev.lower2zlog  The zlog value of the lower reference limit of the preceding age group.
#'                  For the youngest age group the value is set to 0.
#' prev.upper2zlog  The zlog value of the upper reference limit of the preceding age group.
#'                  For the youngest age group the value is set to 0.
#' next.lower2zlog  The zlog value of the lower reference limit of the subsequent age group.
#'                  For the oldest age group the value is set to 0.
#' next.upper2zlog  The zlog value of the upper reference limit of the subsequent age group.
#'                  For the oldest age group the value is set to 0.
#' max.abs.zlog     The largest absolute values of prev.lower2zlog,prev.upper2zlog,next.lower2zlog and 
#'                  next.upper2zlog in the corresponding row.
#'
#' @param datse A data frame that must contain at least the columns CODE, UNIT, AgeFrom, LowerLimit, UpperLimit specifying the 
#' name or abbreviation of the lab parameter, the time unit, the starting age of the age group, and the corresponding lower 
#' and upper reference limit, respectively. NAs and zero entries are not allowed for the reference limits.
#' @param sort.by.age.groups Use the function sort.age.groups()
compute.jumps <- function(datse,sort.by.age.groups=T){
  dats <- datse
  if (sort.by.age.groups){
    dats <- sort.age.groups(datse)    
  }
  mat <- matrix(0,nrow=nrow(dats),ncol=6)
  colnames(mat) <- c("start.time.d","prev.lower2zlog","prev.upper2zlog","next.lower2zlog","next.upper2zlog","max.abs.zlog")
  levs <- levels(factor(dats$CODE))
  for (lev in levs){
    inds <- subset(1:nrow(dats),dats$CODE==lev)
    if (length(inds)>1){
      mat[inds[1],1] <- compute.age(dats$UNIT[inds[1]],dats$AgeFrom[inds[1]])
      
      mat[inds[1],2] <- 0
      mat[inds[1],3] <- 0
      mat[inds[1],4] <- zlog(dats$LowerLimit[inds[2]],L=dats$LowerLimit[inds[1]],U=dats$UpperLimit[inds[1]])
      mat[inds[1],5] <- zlog(dats$UpperLimit[inds[2]],L=dats$LowerLimit[inds[1]],U=dats$UpperLimit[inds[1]])
      
      mat[inds[1],6] <- max(abs(mat[inds[1],2:5]))
      
      if (length(inds)>2){
        for (i in 2:(length(inds)-1)){
          mat[inds[i],1] <- compute.age(dats$UNIT[inds[i]],dats$AgeFrom[inds[i]])
          
          mat[inds[i],2] <- zlog(dats$LowerLimit[inds[i-1]],L=dats$LowerLimit[inds[i]],U=dats$UpperLimit[inds[i]])
          mat[inds[i],3] <- zlog(dats$UpperLimit[inds[i-1]],L=dats$LowerLimit[inds[i]],U=dats$UpperLimit[inds[i]])
          mat[inds[i],4] <- zlog(dats$LowerLimit[inds[i+1]],L=dats$LowerLimit[inds[i]],U=dats$UpperLimit[inds[i]])
          mat[inds[i],5] <- zlog(dats$UpperLimit[inds[i+1]],L=dats$LowerLimit[inds[i]],U=dats$UpperLimit[inds[i]])
          
          mat[inds[i],6] <- max(abs(mat[inds[i],2:5]))
        }
      }
      
      mat[inds[length(inds)],1] <- compute.age(dats$UNIT[inds[length(inds)]],dats$AgeFrom[inds[length(inds)]])
      
      mat[inds[length(inds)],2] <- zlog(dats$LowerLimit[inds[length(inds)-1]],L=dats$LowerLimit[inds[length(inds)]],U=dats$UpperLimit[inds[length(inds)]])
      mat[inds[length(inds)],3] <- zlog(dats$UpperLimit[inds[length(inds)-1]],L=dats$LowerLimit[inds[length(inds)]],U=dats$UpperLimit[inds[length(inds)]])
      mat[inds[length(inds)],4] <- 0
      mat[inds[length(inds)],5] <- 0
      
      mat[inds[length(inds)],6] <- max(abs(mat[inds[length(inds)],2:5]))
      
      mat[inds[1],2] <- NA
      mat[inds[1],3] <- NA
      mat[inds[length(inds)],4] <- NA
      mat[inds[length(inds)],5] <- NA
    }
  }
  return(data.frame(dats,mat))
}

#' Generates a plot which either shows the reference limits depending on the age or the zlog values computed by the function compute.jumps.
#'
#' @param dats Data frame that must contain at least the columns CODE, LowerLimit,UpperLimit and start.time.d specifying 
#' the name or abbreviation of the lab parameter, the corresponding lower and upper reference limit and start time in days of 
#' of the corresponding age group, respectively. In addition the the last columns must contain the values zlog values 
#' prev.lower2zlog, prev.upper2zlog, next.lower2zlog, next.upper2zlog computed by the function compute.jumps. 
#' @param param.code The code of the lab parameter to be plotted.
#' @param use.log If set to TRUE the zlog values will be plotted otherwise the original reference limits.
#' @param pch.prev The symbol for the zlog values of the preceding age group. (Only applicable for use.log=T.)
#' @param pch.next The symbol for the zlog values of the subsequent age group. (Only applicable for use.log=T.)
#' @param col.lower The colour for the zlog value of the lower reference limit if use.log is set to true. 
#' Otherwise the colour of the lower reference limit. 
#' @param col.upper The colour for the zlog value of the upper reference limit if use.log is set to true. 
#' Otherwise the colour of the upper reference limit.
#' @param grid.col If a colour is specified here, a grid with the corresponding colour is added to the plot.
#' @param lty.reflims Line style for the reference limits at -1.96 and 1.96 in the zlog representation. (Only applicable for use.log=T.)
#' @param col.reflims Colour for reference limits at -1.96 and 1.96 in the zlog representation. (Only applicable for use.log=T.)
#' @param lwd.reflims Line width for the reference limits. (Only applicable for use.log=F.)
#' @param xlog If set to true, the x-axis will be shown in log-scale. In this case, one is added to all starting ages 
#' before taking the logarithm to avoid log(0) for the youngest age group.
#' @param ylog If set to true, the y-axis will be shown in log-scale. (Only applicable for use.log=F.)
#' @param cex.pch The size from the zlog values
draw.time.dependent.lims <- function(dats, param.code, use.zlog=T,
                                     pch.prev=15, pch.next=16, col.lower="cornflowerblue", col.upper="indianred", grid.col = T,
                                     lty.reflims=2, col.reflims="seagreen", lwd.reflims=1, xlog=F, ylog=F, cex.pch = 2){
  
  inds <- subset(1:nrow(dats),dats$CODE==param.code)
  datinds <- dats[inds,]
  unit.param <- datinds$LABUNIT[1]
  offset.x <- 0
  log.scale <- ""
  
  if (xlog){
    log.scale <- paste0(log.scale,"x")
    offset.x <- 1
  }
  if (ylog){
    log.scale <- paste0(log.scale,"y")
  }
  
  if (use.zlog){
    minv <- min(datinds$prev.lower2zlog, datinds$prev.upper2zlog, datinds$next.lower2zlog, datinds$next.upper2zlog, na.rm = TRUE)
    maxv <- max(datinds$prev.lower2zlog, datinds$prev.upper2zlog, datinds$next.lower2zlog, datinds$next.upper2zlog, na.rm = TRUE)
    
    plot(NULL,xlim=c(min(datinds$start.time.d)+offset.x,max(datinds$start.time.d)+offset.x),
         ylim=c(minv,maxv),xlab="Age in days",ylab="zlog",log=log.scale,cex=cex.pch)
    if (!is.null(grid.col)){
      grid(col="lightgrey", lwd = 0.5)
    }
    for (i in 1:nrow(datinds)){
      if (i<nrow(datinds)){
        points(datinds$start.time.d[i+1]+offset.x,datinds$next.lower2zlog[i],pch= "\u25C4",col=col.lower,cex=cex.pch)
        points(datinds$start.time.d[i+1]+offset.x,datinds$next.upper2zlog[i],pch= "\u25C4",col=col.upper,cex=cex.pch)
      }
      if (i>1){
        points(datinds$start.time.d[i]+offset.x,datinds$prev.lower2zlog[i],pch= "\U25BA",col=col.lower,cex=cex.pch)
        points(datinds$start.time.d[i]+offset.x,datinds$prev.upper2zlog[i],pch= "\U25BA",col=col.upper,cex=cex.pch)
      }
    }
    # Plot the green lines between -1.96 and 1.96
    abline(qnorm(0.025),b=0,col=col.reflims,lwd=lwd.reflims,lty=lty.reflims)
    abline(qnorm(0.975),b=0,col=col.reflims,lwd=lwd.reflims,lty=lty.reflims)
  
    }
  else{
    minv <- min(datinds$LowerLimit)
    maxv <- max(datinds$UpperLimit)
    
    plot(NULL,xlim=c(min(datinds$start.time.d)+offset.x,max(datinds$start.time.d)+offset.x),
         ylim=c(minv,maxv),xlab="Age in days",ylab=paste(param.code,"(", unit.param, ")"),log=log.scale,cex=cex.pch)
    if (!is.null(grid.col)){
      grid(col="lightgrey", lwd = 0.5)
    }

    #points(datinds$start.time.d+offset.x,datinds$LowerLimit,pch=24,col=col.lower, bg = col.lower, cex=cex.pch)
    #points(datinds$start.time.d+offset.x,datinds$LowerLimit,col=col.lower,type="p",lwd=lwd.reflims,cex=cex.pch)
    
    x_lower <- datinds$start.time.d+offset.x
    y_lower <- datinds$LowerLimit
    
    segments(x_lower[-length(x_lower)],y_lower[-length(x_lower)],x_lower[-1],y_lower[-length(x_lower)])
    lowerlimit <- data.frame(x = x_lower, y = y_lower)
    
    #points(datinds$start.time.d+offset.x,datinds$UpperLimit,pch=25,col=col.upper, bg = col.upper, cex=cex.pch)
    #points(datinds$start.time.d+offset.x,datinds$UpperLimit,col=col.upper,type="s",lwd=lwd.reflims,cex=cex.pch)
  
    x_upper <- datinds$start.time.d+offset.x
    y_upper <- datinds$UpperLimit

    segments(x_upper[-length(x_upper)],y_upper[-length(x_upper)],x_upper[-1],y_upper[-length(x_upper)])
    upperlimit <- data.frame(x = x_upper, y = y_upper)
    
    for (i in 1: (nrow(lowerlimit)-1)){
      
      age <- c(lowerlimit$x[i+1], lowerlimit$x[i], lowerlimit$x[i], lowerlimit$x[i+1])
      
      if(xlog){
        age <- c(lowerlimit$x[i+1], lowerlimit$x[i], lowerlimit$x[i], lowerlimit$x[i+1])
      }
      
      lowerlimit_polygon <- c(lowerlimit$y[i], lowerlimit$y[i])
      upperlimit_polygon <- c(upperlimit$y[i], upperlimit$y[i])
      if(length(lowerlimit_polygon > 1)){
        polygon(age, c(upperlimit_polygon[2], upperlimit_polygon[1], 
                       lowerlimit_polygon[1], lowerlimit_polygon[2]), 
                col = rgb(red = 0 , green = 0, blue = 0, alpha = 0.25), border = NA)
      }
    }
    
  }
}

#' Round numeric values from a dataframe
#' 
#' @param x Expects dataframe
#' @param digits Digits to round
round_df <- function(x, digits) {
  numeric_columns <- sapply(x, mode) == 'numeric'
  x[numeric_columns] <-  round(x[numeric_columns], digits)
  return(x)
}

#' Get the colors to the zlog values
#' 
#' Returns a color between blue via white to red (HEX or RGB)
#' 
#' @param x Expects a (zlog) value x
zlogcolor <- function(x, hex = TRUE,
                      a = c(0, 20), w = c(255, 235), t = c(4, 4),
                      s = c(1.5, 1.5), m = c(-4, -6)){
  
  R = round(a[1] + w[1] / ((1 + t[1] * exp(-s[1] * ( x - m[1]))) ^ (1 / t[1])))
  B = round(a[1] + w[1] / ((1 + t[1] * exp(-s[1] * (-x - m[1]))) ^ (1 / t[1])))
  
  G = sapply(x, function(x) ifelse(x < 0,
    round(a[2] + w[2] / ((1 + t[2] * exp(-s[2] * ( x - m[2]))) ^ (1 / t[2]))),
    round(a[2] + w[2] / ((1 + t[2] * exp(-s[2] * (-x - m[2]))) ^ (1 / t[2])))))

  # if(x < 0) {
  #   G = round(a[2] + w[2] / ((1 + t[2] * exp(-s[2] * ( x - m[2]))) ^ (1 / t[2])))
  # } else {
  #   G = round(a[2] + w[2] / ((1 + t[2] * exp(-s[2] * (-x - m[2]))) ^ (1 / t[2])))
  # }
  
  R[is.na(R)] <- 255
  B[is.na(B)] <- 255
  G[is.na(G)] <- 255
  
  ifelse (hex,
          return(rgb(R, G, B, max = 255)),
          return(c(R, G, B)))
  
}

#' Get the zlog value and check if the background is to dark and change the textcolor to white
#' 
#' Returns a color between blue via white to red (HEX or RGB)
#' 
#' @param x Expects a (zlog) value x
#' @param threshold Given threshold for the zlog value
#' @param background Variable to decide id the color affects the background or the text
highzlogvalues <- function(x, hex = TRUE, threshold = 8, background = FALSE){

  if(!background){
    G = sapply(x, function(x) ifelse(x < -threshold, 255, 0))
    R = sapply(x, function(x) ifelse(x < -threshold, 255, 0))
    B = sapply(x, function(x) ifelse(x < -threshold, 255, 0))
  } else{
    G = sapply(x, function(x) ifelse(x > threshold, 192, 255))
    R = sapply(x, function(x) ifelse(x > threshold, 192, 255))
    B = sapply(x, function(x) ifelse(x > threshold, 192, 255))
  }
  
  R[is.na(R)] <- 0
  B[is.na(B)] <- 0
  G[is.na(G)] <- 0
  
  ifelse (hex,
          return(rgb(R, G, B, max = 255)),
          return(c(R, G, B)))
}
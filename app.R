####################################### Scripts ###################################################

source("zlog.R")

####################################### Libraries #################################################

if("DT" %in% rownames(installed.packages())){
  library(DT)} else{
    install.packages("DT")}

####################################### User Interface ############################################

ui <- fluidPage(
  
  theme = "style.css",
  
    sidebarLayout(
      
      ################################# Sidebar ###################################################
      sidebarPanel(width = 2, h4(strong("Consistency check"),"for Age-dependent Reference Intervals"), hr(),
                   
        selectInput("dataset", "Select Dataset:", choice = list.files(pattern = c(".csv"), recursive = TRUE)),         
        selectInput("parameter", "Select the lab parameter:", choices=1),
        selectInput("sex", "Select the sex:", choices=c("F", "M")), hr(),
        radioButtons("xlog", "Logarithmic scale for the xaxis:",c("No" = FALSE,"Yes" = TRUE)),
        helpText("
              ■ Zlog to the preceding age group", br(),"
              • Zlog to the subsequent age group", br(),"
              ▲ Reference Interval"),
        numericInput("maxzlog", "Maximal Z-Log Value:", 10, min = 1.96, max = 50)
      ),
    
      ################################# Main Panel ################################################
      mainPanel(width = 10,
      
        tabsetPanel(
          tabPanel("Plot", icon = icon("calculator"),
  
              p(strong("Zlog values of your Reference Intervals!"), "This Shiny App computes for each lab parameter 
              and each age group the zlog values of the preceding and the subsequent age group (left plot).
              The zlog value should be optimally in the middle of the green lines between 1.96 and -1.96. Zlog values above 
              4 or -4 should be checked and minimized by adding an additional age group with new calculated reference intervals,
              use the Shiny App AdRI for this. The right plot shows the current used reference intervals. The upper reference limit is in red 
              and the lower limit in blue. New data must be in CSV-format and must contain: CODE (Name of the lab parameter), LABUNIT (Unit),
              SEX, UNIT (period in year, month, week and day), AgeFrom (begin of the age group), AgeUntil (end of the age group),
              LowerLimit (Lower Reference Limit) and UpperLimit (Upper Reference Limit)."),

              plotOutput("plot", height = "600px"), verbatimTextOutput("summary2")), 
          
          tabPanel("Table", icon = icon("table"),  
                   tabPanel("Table", DT::dataTableOutput("table")), verbatimTextOutput("summary"))
        )
      )
    )
  )
  

####################################### Server ####################################################

server <- function(input, output, session) {
  
  options(shiny.sanitize.errors = TRUE)
  
  ##################################### Reactive Expressions ######################################
  
  # Create the table with the zlog values as reactive expression 
  zlog_data <- reactive({
    
    dat <- read.csv2(file=input$dataset,na.strings="")

    ### For replacing missing values. (Not needed if only complete cases are used.)
    minv <- 0.001
    maxv.apc <- 100
    
    ### Store the original data set.
    dat.orig <- dat
    
    ### Remove cases where both the lower and upper limits are not specified. 
    dat <- dat[!is.na(dat$LowerLimit) | !is.na(dat$UpperLimit),]
    
    ### Remove cases where the upper limit is 0.
    dat <- dat[dat$UpperLimit>0,]
    
    ### Use only complete cases.
    dat <- dat[complete.cases(dat),]
    
    ### Not needed unless the previous line dat <- dat[complete.cases(dat),] is not applied.
    dat$UpperLimit[is.na(dat$UpperLimit)] <- maxv.apc
    dat$LowerLimit[is.na(dat$LowerLimit) | dat$LowerLimit==0] <- minv
    
    ### Subset for the men. Note that the reference limits for men and for all are needed.
    datm <- subset(dat,dat$SEX=="M" | dat$SEX=="AL")
    ### Subset for the men. Note that the reference limits for men and for all are needed.
    datf <- subset(dat,dat$SEX=="F" | dat$SEX=="AL")
    
    ### Compute the zlog values of the preceding and subsequent reference limits etc. for men.
    datme <- compute.jumps(datm)
    ### Compute the zlog values of the preceding and subsequent reference limits etc. for women.
    datfe <- compute.jumps(datf)
    
    ### Check the men or women and use the right dataset for datse
    if(input$sex == "M"){datse <- datme}
    if(input$sex == "F"){datse <- datfe}
    
    datse
 })
  
  observeEvent(input$dataset, {
    updateSelectInput(session, "parameter", choices = zlog_data()[,1])
 })
  
  ##################################### Output ####################################################
  
  output$summary <- renderPrint({
   
    datse <- zlog_data()
    print(summary(zlog_data()))
  })
 
  output$summary2 <- renderPrint({
    
    datse <- zlog_data()
    
    ### Check how many and where the absolute zlog value exceeds the given threshold.
    abslim <- input$maxzlog
    
    ### Indices of occurences of large zlog values.
    indscri <- subset(1:nrow(datse),datse$max.abs.zlog>abslim)
    
    ### Names of the lab parameters where large zlog values occur.
    levscri <- levels(factor(datse$CODE[indscri]))
    
    ### No. of occurences of large zlog values.
    cat(paste(sum(datse$max.abs.zlog>abslim, na.rm = TRUE), "Zlog-Values above",abslim,"from this lab parameters: "))
    cat(levscri)
  })
  
 
  output$plot <- renderPlot({
    
    datme <- zlog_data()
    
    ### Draw the graphs for zlog and original reference limits in one figure.
    par(mfrow=c(1,2))
    
    ### Draw the graphs for the given lab parameter
    lab.param <- input$parameter
    
    # to prevent possible error messages because of the slow typing
    validate(need(length(subset(1:nrow(datme),datme$CODE==input$parameter)) > 0, ""))
    
    # check for log for the xaxis
    xlog_ <- input$xlog
    
    # Draw the plots
    draw.time.dependent.lims(datme,lab.param,lwd.reflims=2,xlog=xlog_)
    draw.time.dependent.lims(datme,lab.param,use.zlog=F,lwd.reflims=2,xlog=xlog_)
  })

  output$table <- DT::renderDataTable({
    
    datme <- zlog_data()
    datme <- data.frame(CODE = datme$CODE, SEX = datme$SEX, UNIT = datme$UNIT, round_df(datme[,seq(7,length(datme))],3))
    
    DT::datatable(datme, rownames= FALSE, 
                  caption = htmltools::tags$caption(style = 'caption-side: bottom; text-align: center;', 'Table: Dataset'))
  })
}

####################################### Run the application #######################################
shinyApp(ui = ui, server = server)

####################################### WELCOME TO THE SHINY APP ##################################
####################################### from Sandra Klawitter (2020) ##############################
###################################################################################################


####################################### Load Script and Example-Dataset ###########################

source("zlog.R")
dataset_original <<- read.csv2("data/CALIPER.csv",na.strings="")

####################################### Libraries #################################################

if("DT" %in% rownames(installed.packages())){
  library(DT)} else{
    install.packages("DT")}

####################################### User Interface ############################################

ui <- fluidPage(
  
  theme = "style.css",

    titlePanel(h3("Consistency check for Age-dependent Reference Intervals"), windowTitle = "Zlog"),
    
      sidebarLayout(
      
          ############################# Sidebar ###################################################
          sidebarPanel(width = 3,
            
            fileInput("data_table", "Upload CSV File:", accept = c(
                      "text/csv",
                      "text/comma-separated-values,text/plain",
                      ".csv")),
            
            checkboxInput("replacement", "Replacement values for reference limits", value = FALSE),
            conditionalPanel(
              condition = "input.replacement == 1", 
              numericInput("replace_low", "Replacement value for the lower reference limit:", 
                           0.001, min = 0, max = 100)), 
            conditionalPanel(
              condition = "input.replacement == 1", 
              numericInput("replace_upper", "Replacement value for the upper reference limit:", 
                           100, min = 0.1, max = 1000)),
        
            selectInput("sex", "Select the sex:", choices=c("Female"="F", "Male"="M")),
            selectInput("parameter", "Select the lab parameter:", choices = dataset_original$CODE),
            checkboxInput("xlog", "Logarithmic scale for the x-axis", value = FALSE), hr(),
            numericInput("maxzlog", "Maximum zlog value:", 10, min = 1.96, max = 50), hr(),
            downloadLink("download_data", "Download the Data Table with the zlog values")
        ),
    
      ################################# Main Panel ################################################
      mainPanel(width = 9,

        tabsetPanel(type = "pills",
          
          tabPanel("Home", icon = icon("home"),            

            p(style = "background-color:#A9A9A9;", 

              "This Shiny App computes for each lab parameter the zlog values of the preceding 
              and the subsequent age group. The zlog value should be optimally between -1.96 and 1.96. Zlog values above 
              -4 or 4 should be checked and minimized by adding an additional age group with new 
              calculated reference intervals. New data must be in CSV-format and must contain:",
              br(), br(), "CODE: Name of the lab parameter", br(), "LABUNIT: Unit of the lab parameter", br(),
              "SEX: M for male and F for female", br(), "UNIT: Unit of the age range in year, month, week or day", br(), 
              "AgeFrom: Begin of the age group", br(), "AgeUntil: End of the age group", br(), 
              "LowerLimit: Lower Reference Limit", br(), "UpperLimit: Upper Reference Limit", br(), br(),
              "If the lower or upper reference limit is zero, it will be set with the replacement
              value (default 0.001 or 100)."),  hr(),
            
            htmlOutput("caution"), 
            hr(), htmlOutput("helptext")
          ),
          
          tabPanel("Table", icon = icon("table"), 
            
            p(style = "background-color:#A9A9A9;", 
                     
              "The table shows the zlog values. Zlog values under -1.96 in blue and above 1.96 in orange.
              The zlog value should be optimally between 1.96 and -1.96 in white." ),       
                   
            DT::dataTableOutput("table")),
          
          tabPanel("Plot", icon = icon("calculator"), 
            
            p(style = "background-color:#A9A9A9;", 

              "The first plot shows the current used reference intervals. 
              The upper reference limit is in red and the lower limit in blue.
              The second plot shows for the selected lab parameter and each age group the zlog values 
              of the preceding and the subsequent age group. The zlog value should be optimally in the 
              middle of the green lines between 1.96 and -1.96. Zlog values above 
              4 or -4 should be checked and minimized by adding an additional age group 
              with new calculated reference intervals. Legend: zlog to the preceding age group (square), zlog to the subsequent 
              age group (circle), original reference intervals (triangle)."),
            
            plotOutput("plot", height = "650px")
        ) 
      )
    )
  )
)
  

####################################### Server ####################################################

server <- function(input, output, session) {
  
  options(shiny.plot.res=128)
  options(shiny.sanitize.errors = TRUE)
  
  ##################################### Reactive Expressions ######################################
  
  get_data_file <- reactive({

    saving <- 
      if(!is.null(input$data_table)){
        dataset_original <<- read.csv2(input$data_table[["datapath"]],na.strings="")
      }else{
        dataset_original <<- read.csv2("data/CALIPER.csv",na.strings="")
      }
    return(dataset_original)
  })

  data_caution <- reactive({
  
    dat <- get_data_file()
    validate(need(ncol(dat) == 8, 
                  "Check whether you have used the correct template!"))

    if(input$replacement == TRUE){
      
      minv <- input$replace_low
      maxv.apc <- input$replace_upper
      
      validate(need(minv > 0, ""))
      validate(need(maxv.apc > 0, ""))
    } 
    else{
      minv <- 0.001
      maxv.apc <- 100}
    
    ### Check for upper and lower limit == 0
    indscri <- subset(1:nrow(dat),dat$LowerLimit==0)
    levscri <- levels(factor(dat$CODE[indscri]))
    indscri2 <- subset(1:nrow(dat),dat$UpperLimit==0)
    levscri2 <- levels(factor(dat$CODE[indscri2]))
    
    text <- HTML(paste("<p>",  "Caution with these lab parameters! 
                       The lower reference limit is zero and will be set to", minv ," for",
                       toString(levscri), ". And the upper reference limit is zero and will be set to", 
                       maxv.apc ,"for", toString(levscri2),".</p>"))
    text
  })
  
  
  # Create the table with the zlog values as reactive expression 
  zlog_data <- reactive({
    
    dat <- get_data_file()
    
    validate(need(ncol(dat) == 8, 
                  "Check whether you have used the correct template!"))
    
    if(input$replacement == TRUE){
      
      # to prevent possible error messages because of the slow typing
      minv <- input$replace_low
      maxv.apc <- input$replace_upper
      
      validate(need(minv > 0, ""))
      validate(need(maxv.apc > 0, ""))
    } 
    else{
      minv <- 0.001
      maxv.apc <- 100}
    
    ### Store the original data set.
    dat.orig <- dat
    
    ### Remove cases where both the lower and upper limits are not specified. 
    dat <- dat[!is.na(dat$LowerLimit) | !is.na(dat$UpperLimit),]
    
    ### Remove cases where the upper limit is 0.
    # dat <- dat[dat$UpperLimit>0,]
    
    ### Use only complete cases.
    dat <- dat[complete.cases(dat),]
    
    ### For replacing missing values. (Not needed if only complete cases are used.)
    
    ### Not needed unless the previous line dat <- dat[complete.cases(dat),] is not applied.
    dat$UpperLimit[is.na(dat$UpperLimit) | dat$UpperLimit==0] <- maxv.apc
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

  ##################################### Observe Events ############################################
  
  observeEvent(input$data_table, {
    updateSelectInput(session, "parameter", choices = zlog_data()[,1])
  })
  
  ##################################### Output ####################################################

  helptext <- reactive({
    
    datse <- zlog_data()
    
    ### Check how many and where the absolute zlog value exceeds the given threshold.
    abslim <- input$maxzlog
    
    ### Indices of occurences of large zlog values.
    indscri <- subset(1:nrow(datse),datse$max.abs.zlog>abslim)
    
    ### Names of the lab parameters where large zlog values occur.
    levscri <- levels(factor(datse$CODE[indscri]))
    
    ### No. of occurences of large zlog values.
    text <- HTML(paste("<p>", sum(datse$max.abs.zlog>abslim, na.rm = TRUE), "zlog values above", abslim,
               "from this lab parameters:", toString(levscri), "</p>"))
    text
  })
  
  
  output$caution <- renderUI({ data_caution() })
 
  output$helptext <- renderUI({ helptext() })
  
  output$plot <- renderPlot({
    
    datme <- zlog_data()
    
    ### Draw the graphs for zlog and original reference limits in one figure.
    par(mfrow=c(2,1), mai=c(0.95,0.95,0.15,0.15))
    
    ### Draw the graphs for the given lab parameter
    lab.param <- input$parameter
    
    # to prevent possible error messages because of the slow typing
    validate(need(length(subset(1:nrow(datme),datme$CODE==input$parameter)) > 0, ""))
    
    # check for log for the xaxis
    xlog_ <- input$xlog
    
    # Draw the plots
    draw.time.dependent.lims(datme,lab.param,use.zlog=F,lwd.reflims=2,xlog=xlog_)
    draw.time.dependent.lims(datme,lab.param,lwd.reflims=2,xlog=xlog_)
  })

  output$table <- DT::renderDataTable({
    
    datme <- zlog_data()
    datme <- data.frame(CODE = datme$CODE, SEX = datme$SEX, UNIT = datme$UNIT, 
                        round_df(datme[,seq(7,length(datme))],3))
    
    colnames(datme) <- c("Code", "Sex", "Unit", "Lower Limit", "Upper Limit", "Age", "Prev.lower zlog",
                          "Prev.upper zlog", "Next.lower zlog", "Next.upper zlog", "Max zlog")
    
    if(input$replacement == TRUE){
      DT::datatable(datme, rownames= FALSE, options = list(pageLength = 15, autoWidth = TRUE),
                    caption = htmltools::tags$caption(style = 'caption-side: bottom; text-align: center;', 
                                                      'Table: Dataset with the zlog values')) %>%
        #DT:: formatStyle(columns = "Lower Limit", background = styleEqual(input$replace_low, "indianred")) %>%
        #DT:: formatStyle(columns = "Upper Limit", background = styleEqual(input$replace_upper, "cornflowerblue"))%>%
        DT:: formatStyle(columns = colnames(datme[,c(seq(7,10))]), 
                         backgroundColor = styleInterval(c(-1.9601,0,1.9601), 
                                                         c("cornflowerblue","white","white","coral")))}
      
    else{
      DT::datatable(datme, rownames= FALSE, options = list(pageLength = 15, autoWidth = TRUE),
                    caption = htmltools::tags$caption(style = 'caption-side: bottom; text-align: center;', 
                                                      'Table: Dataset with the zlog values')) %>%
        #DT:: formatStyle(columns = "Lower Limit", background = styleEqual(0.001, "indianred"))%>%
        #DT:: formatStyle(columns = "Upper Limit", background = styleEqual(100, "cornflowerblue"))%>%
        DT:: formatStyle(columns = colnames(datme[,c(seq(7,10))]), 
                         backgroundColor = styleInterval(c(-1.9601,0,1.9601), 
                                                         c("cornflowerblue","white","white","coral")))}
  })


  output$download_data <- downloadHandler(
    filename = function(){
      paste0("Table_Zlog.csv")
    },
    content = function(file) {
      write.csv(zlog_data(), file, row.names = FALSE)
    })
}
####################################### Run the application #######################################
shinyApp(ui = ui, server = server)
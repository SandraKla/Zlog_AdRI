####################################### WELCOME TO THE SHINY APP ##################################
####################################### from Sandra K. (2022) #####################################
###################################################################################################

####################################### Load Script and Example-Dataset ###########################

source("zlog.R")
dataset_original <- read.csv("data/CALIPER.csv",na.strings="", fileEncoding="latin1")

####################################### Libraries #################################################

if("DT" %in% rownames(installed.packages())){
  library(DT)} else{
    install.packages("DT")}

####################################### User Interface ############################################

ui <- fluidPage(
  
  theme = "style.css",

    titlePanel("", windowTitle = "zlog"),
    
      sidebarLayout(
      
          ############################# Sidebar ###################################################
          sidebarPanel(width = 3,
            
            h3("Tool for Plausibility Checks of Reference Interval Limits"), br(),          
                       
            fileInput("data_table", "Upload CSV File:", accept = c(
                      "text/csv",
                      "text/comma-separated-values,text/plain",
                      ".csv")), #hr(),
            
            #helpText("Settings for the calculation of the zlog-value:"),
            #checkboxInput("replacement", "Customize replacement values for the RI", value = FALSE),
            #conditionalPanel(
            #  condition = "input.replacement == 1", 
            #  numericInput("replace_low", "Replacement value for the LL:", 
            #               0.001, min = 0, max = 100)), 
            #conditionalPanel(
            #  condition = "input.replacement == 1", 
            #  numericInput("replace_upper", "Replacement value for the UL:", 
            #               100, min = 0.1, max = 1000)), 
            
            #hr(),
            
            conditionalPanel(
              condition = "input.tabselected == 'Table'", 
              selectInput("sex", "Select the sex:", choices = #c("All (AL)"="B", "Female (F)"="F", "Male (M)"="M"))),
                            c("Female (F)"="F", "Male (M)"="M"))),
            conditionalPanel(
              condition = "input.tabselected == 'Plot'", 
              selectInput("sex_plot", "Select the sex:", choices = c("Female (F)"="F", "Male (M)"="M"))),
            
            conditionalPanel(
              condition = "input.tabselected == 'Plot'", hr(),
            selectInput("parameter", "Select the lab parameter:", choices = dataset_original$CODE, 
                        selected = TRUE)),
            conditionalPanel(
              condition = "input.tabselected == 'Plot'",
              selectInput("xaxis_scale", "Select the x-axis scaling:", 
                          choices = c("Days"="days", 
                                      "Years"="years",
                                      "Days/Years"="days_years"),
                          selected = TRUE)),
            conditionalPanel(
              condition = "input.tabselected == 'Plot'", 
            checkboxInput("xlog", "Logarithmic scale for the x-axis", value = FALSE)), 
            
            hr(),
            
            numericInput("maxzlog", "Maximum absolute zlog value:", 10, min = 0, max = 50),
            htmlOutput("helptext"),
            
            hr(),
            
            helpText("For further information visit our", a("Website", href="https://sandrakla.github.io/Zlog_AdRI/"),"!")
                     # br(), "Link to the publication: A Tool for Plausibility Checks of Reference Interval Limits")
        ),
    
      ################################# Main Panel ################################################
      mainPanel(width = 9,

        tabsetPanel(type = "pills", id = "tabselected", 
          
          tabPanel("Table", icon = icon("table"),        

            p(style = "background-color:#A9A9A9;", 

              "This Shiny App computes the zlog values of the preceding and the subsequent reference 
              interval (RI) for different analytes for each age group. Many medical RI are 
              not age-dependent and have large jumps between the individual age groups. 
              This should be prevented by considering the zlog value. The zlog value should be optimally 
              between -1.96 and 1.96. The further away the values, the more likely the RI jump is implausible."), 
            htmlOutput("caution"),
          
            #downloadButton("download_data_example", icon = icon("download"), "Download the example data"),
            DT::dataTableOutput("table")),
          
          tabPanel("Plot", icon = icon("calculator"),
            
            p(style = "background-color:#A9A9A9;", 

              "Original RI (top) and zlog values for the selected lab analytes for each age group (bottom). 
              The direction of the triangles in the lower figure indicates the zlog values of the preceding (left) and the 
              following age group (right). 
              Blue color indicates lower, red the upper reference limits. 
              The dotted green lines represent the common reference interval of -1.96 to +1.96. 
              The further the traingles are from these lines, the more likely there is an implausible age jump."),
            
            plotOutput("plot", height = "700px")
        ) 
      )
    )
  )
)
  

####################################### Server ####################################################

server <- function(input, output, session) {
  
  options(shiny.plot.res=128)
  options(shiny.sanitize.errors = TRUE)
  options(warn = -1)
  
  ##################################### Reactive Expressions ######################################
  
  get_data_file <- reactive({

    saving <- 
      if(!is.null(input$data_table)){
        dataset_original <- read.csv(input$data_table[["datapath"]],na.strings="", fileEncoding="latin1")
      }else{
        dataset_original <- read.csv("data/CALIPER.csv",na.strings="", fileEncoding="latin1")
      }
    return(dataset_original)
  })

  data_caution <- reactive({
  
    dat <- get_data_file()

    ### Check for upper and lower limit == 0
    indscri <- subset(1:nrow(dat),dat$LowerLimit==0)
    levscriage <- paste0(dat$CODE[indscri], " (", dat$AgeFrom[indscri], "-", dat$AgeUntil[indscri], " ", dat$UNIT[indscri], "s)")
    indscri2 <- subset(1:nrow(dat),dat$UpperLimit==0)
    levscri2age <- paste0(dat$CODE[indscri2], " (", dat$AgeFrom[indscri2], "-", dat$AgeUntil[indscri2], " ", dat$UNIT[indscri2], "s)")
    
    levscri <- levels(factor(dat$CODE[indscri]))
    levscri2 <- levels(factor(dat$CODE[indscri2]))
    
    if(length(levscri) <= 1){
        zero_lower <- paste("The Lower Limit (LL) for this lab parameter is zero:", toString(levscriage), ".")
        if(length(levscri) == 0){
            zero_lower <- ""
        }
    } else{
        zero_lower <- paste("The Lower Limit (LL) for these lab parameters is zero:", toString(levscriage), ".")
    }
    
    if(length(levscri2) <= 1){
      zero_upper <- paste("The Upper Limit (UL) for this lab parameter is zero:", toString(levscri2age), ".")
      if(length(levscri2) == 0){
        zero_upper <- ""
      }
    } else{
      zero_upper <- paste("The Upper Limit (UL) for these lab parameters is zero:", toString(levscri2age), ".")
    }
    
    text <- HTML(paste("<p>", zero_lower, zero_upper,"</p>"))
    
    if(zero_lower == "" && zero_upper == ""){
      text = "";
    }

    text
  })
  
  
  # Create the table with the zlog values as reactive expression 
  zlog_data <- reactive({
    
    dat <- get_data_file()
    
    validate(need(ncol(dat) == 8, 
                  "Check if you have used the correct template!"))
    
    # if(input$replacement == TRUE){
    #   
    #   # to prevent possible error messages because of the slow typing
    #   minv <- input$replace_low
    #   maxv.apc <- input$replace_upper
    #   
    #   validate(need(minv > 0, ""))
    #   validate(need(maxv.apc > 0, ""))
    # } 
    # else{
    #   minv <- 0.001 
    #   maxv.apc <- 100}
    
    ### Store the original data set.
    dat.orig <- dat
    
    ### Remove cases where both the lower and upper limits are not specified. 
    dat <- dat[!is.na(dat$LowerLimit) | !is.na(dat$UpperLimit),]
    
    ### Remove cases where the upper limit is 0.
    dat <- dat[dat$UpperLimit>0,]

    ### Use only complete cases.
    dat <- dat[complete.cases(dat),]
    
    ### For replacing missing values. (Not needed if only complete cases are used.)
    
    ### Not needed unless the previous line dat <- dat[complete.cases(dat),] is not applied.
    #dat$UpperLimit[is.na(dat$UpperLimit) | dat$UpperLimit==0] <- maxv.apc
    dat$LowerLimit[is.na(dat$LowerLimit) | dat$LowerLimit==0] <- NA
    
    ### Subset for the men. Note that the reference limits for men and for all are needed.
    datm <- subset(dat,dat$SEX=="M" | dat$SEX=="MF")
    ### Subset for the women. Note that the reference limits for men and for all are needed.
    datf <- subset(dat,dat$SEX=="F" | dat$SEX=="MF")
    ### Subset for the men and women. Note that the reference limits for men and for all are needed.
    datb <- dat
    
    ### Compute the zlog values of the preceding and subsequent reference limits etc. for men.
    datme <- compute.jumps(datm)
    ### Compute the zlog values of the preceding and subsequent reference limits etc. for women.
    datfe <- compute.jumps(datf)
    ### Compute the zlog values of the preceding and subsequent reference limits etc. for women and men.
    datbe <- compute.jumps(datb)
    
    ### Check the men or women and use the right dataset for datse
    
    if(input$tabselected == "Table"){
      if(input$sex == "M"){datse <- datme}
      if(input$sex == "F"){datse <- datfe}
      if(input$sex == "MF"){datse <- datbe}
    }
    if(input$tabselected == "Plot"){
      if(input$sex_plot == "M"){datse <- datme}
      if(input$sex_plot == "F"){datse <- datfe}
    }
    
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
    
    ### Indices of occurrences of large zlog values.
    indscri <- subset(1:nrow(datse),datse$max.abs.zlog>abslim)
    
    ### Names of the lab parameters where large zlog values occur.
    levscri <- levels(factor(datse$CODE[indscri]))
    
    ### No. of occurrences of large zlog values.
    if(length(levscri) == 1){
      text <- HTML(paste("<p>", sum(datse$max.abs.zlog>abslim, na.rm = TRUE), "zlog values above", abslim,
                  "from this lab parameter:", toString(levscri), "</p>"))}
    else{
      text <- HTML(paste("<p>", sum(datse$max.abs.zlog>abslim, na.rm = TRUE), "zlog values above", abslim,
                  "from these lab parameters:", toString(levscri), "</p>"))
    }
    
    if(length(levscri) == 0){
      text <- HTML(paste("<p> No zlog value is above", abslim),".</p>")
    }
    
    text
  })
  
  
  output$caution <- renderUI({ data_caution() })
 
  output$helptext <- renderUI({ helptext() })
  
  output$plot <- renderPlot({
    
    datme <- zlog_data()
    #cairo_ps(file = "Figure1.eps", onefile = FALSE, fallback_resolution = 1200)
    
    ### Draw the graphs for zlog and original reference limits in one figure.
    par(mfrow=c(2,1), mai=c(0.95,0.95,0.15,0.15))
    
    ### Draw the graphs for the given lab parameter
    lab.param <- input$parameter
    
    # to prevent possible error messages because of the slow typing
    validate(need(length(subset(1:nrow(datme),datme$CODE==input$parameter)) > 0, ""))
    
    # check for log for the xaxis
    xlog_ <- input$xlog
    xaxis_scale_ <- input$xaxis_scale
    
    if(xaxis_scale_ == "days_years"){
      par(mfrow=c(2,1), mai=c(1.5,0.95,0.15,0.15))
    }
    
    # Draw the plots
    draw.time.dependent.lims(datme,lab.param, use.zlog=F,lwd.reflims=2,xlog=xlog_, xaxis_scale = xaxis_scale_)
    draw.time.dependent.lims(datme,lab.param, lwd.reflims=2,xlog=xlog_, xaxis_scale = xaxis_scale_)
    #dev.off()
  })

  output$table <- DT::renderDataTable({
    
    datme <- zlog_data()

    datme <- data.frame(CODE = datme$CODE, SEX = datme$SEX, AGE = 
                          paste0(datme$AgeFrom, "-", datme$AgeUntil, " (", datme$UNIT, "s)"), 
                          round_df(datme[,seq(7,length(datme))],3))
    
    datme$start.time.d <- NULL
    colnames(datme) <- c("Code", "Sex", "Age", "Lower Limit", "Upper Limit", "Prev.lower zlog",
                         "Prev.upper zlog", "Next.lower zlog", "Next.upper zlog", "Max.abs.zlog")

    options(htmlwidgets.TOJSON_ARGS = list(na = 'string'))
     
    # if(input$replacement == TRUE){
    #   DT::datatable(datme, rownames= FALSE, extensions = 'Buttons',
    #                 options = list(dom = 'Blfrtip', pageLength = 15, buttons = c('copy', 'csv', 'pdf', 'print')),
    #                 caption = htmltools::tags$caption(style = 'caption-side: bottom; text-align: center;', 
    #                                                   'Table: Dataset with the zlog values')) %>%
    #     DT:: formatStyle(columns = "Prev.lower zlog", color = styleEqual(datme[,5], highzlogvalues(c(datme[,5]))),
    #                      backgroundColor =  styleEqual(datme[,5], zlogcolor(c(datme[,5])))) %>%
    #     DT:: formatStyle(columns = "Prev.upper zlog", color = styleEqual(datme[,6], highzlogvalues(c(datme[,6]))),
    #                      backgroundColor =  styleEqual(datme[,6], zlogcolor(c(datme[,6])))) %>%
    #     DT:: formatStyle(columns = "Next.lower zlog", color = styleEqual(datme[,7], highzlogvalues(c(datme[,7]))),
    #                      backgroundColor =  styleEqual(datme[,7], zlogcolor(c(datme[,7])))) %>%
    #     DT:: formatStyle(columns = "Next.upper zlog", color = styleEqual(datme[,8], highzlogvalues(c(datme[,8]))),
    #                      backgroundColor =  styleEqual(datme[,8], zlogcolor(c(datme[,8])))) %>%
    #     DT:: formatStyle(columns = "Max.abs.zlog", color = styleEqual(datme[,9], highzlogvalues(c(datme[,9]))),
    #                      backgroundColor =  styleEqual(datme[,9], zlogcolor(c(datme[,9]))))
    #   
    # }
    # else{
    #   DT::datatable(datme, rownames= FALSE, extensions = 'Buttons',
    #                 options = list(dom = 'Blfrtip', pageLength = 15, buttons = c('copy', 'csv', 'pdf', 'print')),
    #                 caption = htmltools::tags$caption(style = 'caption-side: bottom; text-align: center;', 
    #                                                   'Table: Dataset with the zlog values')) %>%
    #     DT:: formatStyle(columns = "Prev.lower zlog", color =  styleEqual(datme[,5], highzlogvalues(c(datme[,5]))),
    #                      backgroundColor =  styleEqual(datme[,5], zlogcolor(c(datme[,5])))) %>%
    #     DT:: formatStyle(columns = "Prev.upper zlog", color =  styleEqual(datme[,6], highzlogvalues(c(datme[,6]))),
    #                      backgroundColor =  styleEqual(datme[,6], zlogcolor(c(datme[,6])))) %>%
    #     DT:: formatStyle(columns = "Next.lower zlog", color =  styleEqual(datme[,7], highzlogvalues(c(datme[,7]))),
    #                      backgroundColor =  styleEqual(datme[,7], zlogcolor(c(datme[,7])))) %>%
    #     DT:: formatStyle(columns = "Next.upper zlog", color =  styleEqual(datme[,8], highzlogvalues(c(datme[,8]))),
    #                      backgroundColor =  styleEqual(datme[,8], zlogcolor(c(datme[,8])))) %>%
    #     DT:: formatStyle(columns = "Max.abs.zlog",color = styleEqual(datme[,9], highzlogvalues(c(datme[,9]))),
    #                      backgroundColor =  styleEqual(datme[,9], zlogcolor(c(datme[,9]))))
    #     }
    
    # if(input$replacement == TRUE){
    #   DT::datatable(datme, rownames= FALSE, extensions = 'Buttons',
    #                 options = list(dom = 'Blfrtip', pageLength = 15, buttons = c('copy', 'csv', 'pdf', 'print')),
    #                 caption = htmltools::tags$caption(style = 'caption-side: bottom; text-align: center;',
    #                                                   'Table: Dataset with the zlog values')) %>%
    #     DT:: formatStyle(columns = "Max.abs.zlog", color = styleEqual(datme[,10], highzlogvalues(c(datme[,10]))),
    #                      backgroundColor =  styleEqual(datme[,10], zlogcolor(c(datme[,10]))))

    #}
    #else{
      DT::datatable(datme, rownames= FALSE, extensions = 'Buttons',
                    options = list(dom = 'Blfrtip', pageLength = 15, buttons = c('copy', 'csv', 'pdf', 'print')),
                    caption = htmltools::tags$caption(style = 'caption-side: bottom; text-align: center;',
                                                      'Table: Dataset with the zlog values')) %>%
        DT:: formatStyle(columns = "Max.abs.zlog",color = styleEqual(datme[,9], highzlogvalues(c(datme[,10]))),
                         backgroundColor =  styleEqual(datme[,10], zlogcolor(c(datme[,10]))))
        #}
  })

  # output$download_data <- downloadHandler(
  #   filename = function(){
  #     paste0("Table_Zlog.csv")
  #   },
  #   content = function(file) {
  #     
  #     datme <- zlog_data()
  #     datme <- data.frame(CODE = datme$CODE, SEX = datme$SEX, UNIT = datme$UNIT, 
  #                         round_df(datme[,seq(7,length(datme))],3))
  #     
  #     colnames(datme) <- c("Code", "Sex", "Unit", "Lower Limit", "Upper Limit", "Age", "Prev.lower zlog",
  #                          "Prev.upper zlog", "Next.lower zlog", "Next.upper zlog", "Max zlog")
  #     
  #     write.csv(datme, file, row.names = FALSE)
  #   })
  
  # output$download_data_example <- downloadHandler(
  #   filename = function(){
  #     paste0("Table_CALIPER.csv")
  #   },
  #   content = function(file) {
  #     
  #     dataset_original <- read.csv("data/CALIPER.csv",na.strings="")
  #     write.csv(datme, file, row.names = FALSE)
  #   })
}
####################################### Run the application #######################################
shinyApp(ui = ui, server = server)
library(shiny, lib.loc="lib")
library(tidyverse, lib.loc="lib")

x = read_csv("data/causeOfDeath.csv", col_types=cols())

shinyUI(fluidPage(
    
    titlePanel("Leading Causes of Death in Canada"),
    
    # Sex data selection
    radioButtons("dataSource", "Dataset",
                 c("Females and Males",
                   "Females",
                   "Males")),
    
    sidebarLayout(
        sidebarPanel(
            # Settings sidebar for Barplot panel
            conditionalPanel(condition="input.activeTab == 'barplot'",
                             helpText(HTML("<h3>Settings</h3>")),
                             
                             # Number of causes selection
                             sliderInput("barNumber", "Number of Causes to Show",
                                         min=1, max=length(colnames(x))-5, value=10),
                             
                             # Age range selection
                             selectInput("barAge", "Age at Time of Death", unique(x$Age)),
                             
                             # Date range selection
                             sliderInput("barRange", "Date Range",
                                         min=2000, max=2019, value=c(2000, 2019), sep="")
                             ),
            
            # Settings sidebar for Time Series panel
            conditionalPanel(condition="input.activeTab == 'ts'",
                             helpText(HTML("<h3>Settings</h3>")),
                             
                             # Data characteristic to display
                             selectInput("tsCharacteristic", "Data to Display",
                                         c("Number of deaths",
                                           "Percentage of deaths",
                                           "Age-specific mortality rate per 100,000 population")),
                             
                             # Cause of death selection
                             selectInput("tsCause", "Cause of Death [ICD-10]",
                                         choices=colnames(x)[5:length(colnames(x))]),
                             
                             # Age range selection
                             selectInput("tsAge", "Age at Time of Death", unique(x$Age)),
                             
                             # Date range selection
                             sliderInput("tsRange", "Date Range",
                                         min=2000, max=2019, value=c(2000, 2019), sep=""),
                             
                             # Smoothing option
                             checkboxInput("tsSmooth", strong("LOESS"), TRUE),
                             
                             # Linear regression option
                             checkboxInput("tsLM", strong("Linear Regression"), FALSE))),
        
        
        mainPanel(
            tabsetPanel(type="tabs", id="activeTab",
                        tabPanel("Barplot", value="barplot", plotOutput("barplot")),
                        tabPanel("Time Series", value="ts", plotOutput("tsPlot")),
                        tabPanel("About", value="about",
                                 tabsetPanel(type="pills",
                                             tabPanel("Data", source("assets/ui/aboutData.R")$value()),
                                             tabPanel("Author", source("assets/ui/aboutAuthor.R")$value()))))
        )
    )
))

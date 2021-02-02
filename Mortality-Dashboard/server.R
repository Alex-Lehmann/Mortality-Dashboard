#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(shiny)

shinyServer(function(input, output){
  
  # Reactive data loading #################################################################
  x = reactive({
    if (input$dataSource == "Females and Males"){
      read_csv("data/causeOfDeath_both.csv", col_types=cols())
    } else if (input$dataSource == "Females"){
      read_csv("data/causeOfDeath_females.csv", col_types=cols())
    } else if (input$dataSource == "Males"){
      read_csv("data/causeOfDeath_males.csv", col_types=cols())
    } else {NULL}
  })
  
  # Time series plot ######################################################################
  output$tsPlot = renderPlot({
    # Pull requested data
    x = x() %>%
      filter(Characteristics == input$tsCharacteristic,
             Age == input$tsAge,
             Year %in% input$tsRange[1]:input$tsRange[2]) %>%
      select(Year, input$tsCause)
    colnames(x) = c("Year", "y")
    
    # Generate plot
    if (!input$tsSmooth & !input$tsLM){
      ggplot(x, aes(x=Year, y=y)) +
        geom_point() +
        ggtitle(str_to_title(paste0(input$tsCharacteristic,
                                    " From ",
                                    input$tsCause,
                                    ", ",
                                    input$tsRange[1], "-", input$tsRange[2],
                                    ", ",
                                    input$dataSource,
                                    ", ",
                                    input$tsAge))) +
        xlab("Year") +
        ylab(str_to_title(input$tsCharacteristic))
    } else if (input$tsSmooth & !input$tsLM){
      ggplot(x, aes(x=Year, y=y)) +
        geom_point() +
        geom_smooth(method="loess", formula=y~x) +
        ggtitle(str_to_title(paste0(input$tsCharacteristic,
                                    " From ",
                                    input$tsCause,
                                    ", ",
                                    input$tsRange[1], "-", input$tsRange[2],
                                    ", ",
                                    input$dataSource,
                                    ", ",
                                    input$tsAge))) +
        xlab("Year") +
        ylab(str_to_title(input$tsCharacteristic))
    } else if (!input$tsSmooth & input$tsLM){
      ggplot(x, aes(x=Year, y=y)) +
        geom_point() +
        geom_smooth(method="lm", color="red", formula=y~x) +
        ggtitle(str_to_title(paste0(input$tsCharacteristic,
                                    " From ",
                                    input$tsCause,
                                    ", ",
                                    input$tsRange[1], "-", input$tsRange[2],
                                    ", ",
                                    input$dataSource,
                                    ", ",
                                    input$tsAge))) +
        xlab("Year") +
        ylab(str_to_title(input$tsCharacteristic))
    } else if (input$tsSmooth & input$tsLM){
      ggplot(x, aes(x=Year, y=y)) +
        geom_point() +
        geom_smooth(method="loess", formula=y~x) +
        geom_smooth(method="lm", color="red", formula=y~x) +
        ggtitle(str_to_title(paste0(input$tsCharacteristic,
                                    " From ",
                                    input$tsCause,
                                    ", ",
                                    input$tsRange[1], "-", input$tsRange[2],
                                    ", ",
                                    input$dataSource,
                                    ", ",
                                    input$tsAge))) +
        xlab("Year") +
        ylab(str_to_title(input$tsCharacteristic))
    }
  })
  
  # Barplot ###############################################################################
  output$barplot = renderPlot({
    # Pull requested data and aggregate by cause, then pull only top N causes
    x = x() %>%
      filter(Characteristics == "Number of deaths",
             Age == input$barAge,
             Year %in% input$barRange[1]:input$barRange[2]) %>%
      select(-c(Age, Characteristics)) %>%
      pivot_longer(!Year, names_to="Cause", values_to="Value") %>%
      group_by(Cause) %>%
      summarize(Value = sum(Value)) %>%
      top_n(input$barNumber, Value)
    
    # Generate plot
    ggplot(x, aes(x=reorder(Cause, -Value), y=Value)) +
      geom_bar(stat="boxplot") +
      theme(axis.text.x = element_text(angle=90, vjust=0.5, hjust=1)) +
      scale_fill_gradient(low="red", high="blue") +
      ggtitle(str_to_title(paste0("Top ",
                                  input$barNumber,
                                  " Leading Causes of Death in Canada, ",
                                  input$barRange[1], "-", input$barRange[2],
                                  ", ",
                                  input$dataSource,
                                  ", ",
                                  input$barAge))) +
      xlab("Cause of Death") +
      ylab("Number of DeathS")
  })
})

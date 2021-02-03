library(shiny, lib.loc="lib")
library(tidyverse, lib.loc="lib")

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
    tsPlot = ggplot(x, aes(x=Year, y=y)) +
      geom_point() +
      xlab("Year") +
      ylab(str_to_title(input$tsCharacteristic))
    
    # Dynamic title
    if (input$tsRange[1] == input$tsRange[2]){
      tsDates = input$tsRange[1]
    } else {
      tsDates = paste0(input$tsRange[1], "-", input$tsRange[2])
    }
    tsPlot = tsPlot +
      ggtitle(str_to_title(paste0(input$tsCharacteristic,
                                  " From ",
                                  input$tsCause,
                                  ", ",
                                  tsDates,
                                  ", ",
                                  input$dataSource,
                                  ", ",
                                  input$tsAge)))
    
    # Smoothers
    if (input$tsSmooth){tsPlot = tsPlot + geom_smooth(method="loess", formula=y~x, color="blue")}
    if (input$tsLM){tsPlot = tsPlot + geom_smooth(method="lm", formula=y~x, color="red")}
    
    # Return final plot
    tsPlot
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
    
    # Shorten cause names to ICD-10 codes
    x = mutate(x, Cause = str_extract(Cause, "(\\[.*\\]$)|(\\bOther causes of death\\b)"))
    
    # Generate plot
    barplot = ggplot(x, aes(x=reorder(Cause, -Value), y=Value)) +
      geom_bar(stat="boxplot") +
      theme(axis.text.x = element_text(angle=90, vjust=0.5, hjust=1)) +
      xlab("Cause of Death [ICD-10]") +
      ylab("Number of DeathS")
    
    # Dynamic title
    if (input$barRange[1] == input$barRange[2]){
      barDates = input$barRange[1]
    } else {
      barDates = paste0(input$barRange[1], "-", input$barRange[2])
    }
    barplot = barplot +
      ggtitle(str_to_title(paste0("Top ",
                                  input$barNumber,
                                  " Leading Causes of Death in Canada, ",
                                  barDates,
                                  ", ",
                                  input$dataSource,
                                  ", ",
                                  input$barAge)))
    barplot
  })
  
  # Hacky LinkedIn badge ##################################################################
  output$badge = renderImage({
    list(src = "assets/img/linkedin badge.png",
         contentType = "image/png")
  }, deleteFile = FALSE)
})

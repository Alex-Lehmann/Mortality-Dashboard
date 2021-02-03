function(){
  tabPanel("Data",
           HTML("<h1>Leading Causes of Death in Canada Dashboard</h1>
                <p>Developed using R Shiny for STAT 5702, Modern and Applied Computational Statistics, at Carleton University in Winter 2021.</p>
                <p>This app displays data regarding the 50 leading causes of death in Canada between the years 2000 and 2019. The purpose is to visualize the changes and relative effects of these causes of death over time. This could be used to quickly and easily identify areas of interest in the data to drive further investigation at a later date.</p>
                <p>Time series plots show the change in deaths from each cause on an annual basis and a barplot relates the numbers of deaths from different causes. Each plot can be adjusted to show data by sex, age, and date range. The time series plots can include LOESS and linear regression lines as well.</p>"),
           HTML("<h3>Data Source</h3>
                Statistics Canada. <a href='https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1310039401'><u>Table 13-10-0394-01  Leading causes of death, total population, by age group</u></a><br>
                DOI: <a href='https://doi.org/10.25318/1310039401-eng'><u>https://doi.org/10.25318/1310039401-eng</u></a>"),
           value="aboutData")
}

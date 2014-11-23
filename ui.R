library(shiny)

shinyUI(fluidPage(
    navbarPage(h3("Annual GDP (1961-2013)"), inverse=TRUE,
               tabPanel(h5("GDP tool"),
                        sidebarPanel(
                            helpText("Create annual GDP time series plots with data from the World Bank."),
                            sliderInput("range", label = h5("Year range of interest:"),
                                        min = 1961, max = 2013, value = c(1961, 2013), format="####"),
                            uiOutput("econControls"),
                            helpText("Hold down the Ctrl key to select multiple countries."),
                            div("Error might occur in plotting whenever data is not available. Choose 
                                a different year range.", 
                                style = "color:blue")
                        ),
                        
                        mainPanel(
                            tabsetPanel(
                                tabPanel("Plot",
                                         plotOutput("plot1"),
                                         br(),
                                         plotOutput("plot3"),
                                         br(),
                                         plotOutput("plot2"),
                                         br(),
                                         textOutput("text"),
                                         br(),
                                         tableOutput("values")
                                ),
                                tabPanel("GDP data",
                                         dataTableOutput(outputId="table1")
                                ),
                                tabPanel("GDP per capita data",
                                         dataTableOutput(outputId="table3")
                                ),
                                tabPanel("GDP growth data",
                                         dataTableOutput(outputId="table2")
                                )
                            )
                        )
               ),
               tabPanel(h5("About"),
                        helpText("This application is based on the World GDP data obtained from the World 
                                 website (http://data.worldbank.org/indicator/)."),
                        br(),
                        helpText("The data consists of GDP at purchaser's prices, GDP per capita, 
                                 and annual percentage growth rate of GDP at market price 
                                 for each country from 1961 to 2013"),
                        br(),
                        helpText("GDP is defined to be the sum of gross value added by all resident 
                                 producers in the economy plus any product taxes and minus any subsidies not 
                                 included in the value of the products. It is calculated without making 
                                 deductions for depreciation of fabricated assets or for depletion and 
                                 degradation of natural resources."),
                        br(),
                        helpText("GDP are in current U.S. dollars. Dollar figures for GDP are converted 
                                 from domestic currencies using single year official exchange rates. 
                                 For a few countries where the official exchange rate does not reflect 
                                 the rate effectively applied to actual foreign 
                                 exchange transactions, an alternative conversion factor is used."),
                        br(),
                        helpText("GDP per capita is gross domestic product divided by midyear population
                                 in current U.S. dollars. Annual percentage growth rate of GDP at market 
                                 prices is based on constant local currency. Aggregates are based on 
                                 constant 2005 U.S. dollars. ")
               )
    )
))
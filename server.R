library(shiny)
library(reshape2)
library(ggplot2)

economies = list("Afghanistan", "Albania", "Algeria", "Andorra", 
                 "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", 
                 "Azerbaijan", "Bahamas, The", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", 
                 "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", 
                 "Brazil", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", 
                 "Cambodia", "Cameroon", "Canada", "Cayman Islands", "Central African Republic", "Chad", 
                 "Channel Islands", "Chile", "China", "Colombia", "Comoros", "Congo, Dem. Rep.", 
                 "Congo, Rep.", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", 
                 "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", 
                 "Egypt, Arab Rep.", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", 
                 "Faeroe Islands", "Fiji", "Finland", "France", "French Polynesia", "Gabon",  "Gambia, The", 
                 "Georgia", "Germany", "Ghana", "Greece", "Greenland", "Grenada", "Guatemala", 
                 "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hong Kong SAR, China", 
                 "Hungary", "Iceland", "India", "Indonesia", "Iran, Islamic Rep.", "Iraq", "Ireland", 
                 "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", 
                 "Kiribati", "Korea, Rep.", "Kosovo", "Kuwait", "Kyrgyz Republic", 
                 "Lao PDR", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", 
                 "Lithuania", "Luxembourg", "Macao SAR, China", "Macedonia, FYR", "Madagascar", "Malawi", 
                 "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", 
                 "Mexico", "Micronesia, Fed. Sts.", "Moldova", "Monaco", "Mongolia", "Montenegro", 
                 "Morocco", "Mozambique", "Namibia", "Nepal", "Netherlands", "New Caledonia", 
                 "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norway", 
                 "Oman", "Pakistan", "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", 
                 "Philippines", "Poland", "Portugal", "Puerto Rico", "Qatar", "Romania", 
                 "Russian Federation", "Rwanda", "Samoa", "San Marino", "Sao Tome and Principe", 
                 "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", 
                 "Slovak Republic", "Slovenia", "Solomon Islands", 
                 "Somalia", "South Africa", "South Sudan", "Spain", "Sri Lanka", "St. Kitts and Nevis", 
                 "St. Lucia", "St. Vincent and the Grenadines", "Sudan", 
                 "Suriname", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic", "Tajikistan", 
                 "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", 
                 "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", 
                 "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", 
                 "Vanuatu", "Venezuela, RB", "Vietnam", "Virgin Islands (U.S.)", "West Bank and Gaza", 
                 "Yemen, Rep.", "Zambia", "Zimbabwe")


#Load data
dtAux <- read.csv("data/metadata_gdp.csv") 
dtAux <- subset(dtAux, select=c(Country.Code, Region, IncomeGroup))

dt1 <- read.csv("data/data_gdp.csv") #GDP (current US$)
dt1 <- subset(dt1, select=-c(Indicator.Name, Indicator.Code))
dtMerged1 <- merge(dtAux, dt1, by="Country.Code")

dt2 <- read.csv("data/data_growth.csv") #GDP growth (annual %)
dt2 <- subset(dt2, select=-c(Indicator.Name, Indicator.Code))
dtMerged2 <- merge(dtAux, dt2, by="Country.Code")

dt3 <- read.csv("data/data_capita.csv") #GDP per capita (current US$)
dt3 <- subset(dt3, select=-c(Indicator.Name, Indicator.Code))
dtMerged3 <- merge(dtAux, dt3, by="Country.Code")

#Data preprocessing
Year <- 1960:2013
countryNames <- as.character(dtMerged1$Country.Name)
dt1a <- subset(dtMerged1, select=-c(Country.Code, Region, IncomeGroup, Country.Name))
dt1a <- data.frame(cbind(Year, t(dt1a)))
colnames(dt1a) <- c("Year", countryNames)
dtgdp <- subset(dt1a, select=-c(1960))

Year <- 1961:2014
countryNames <- as.character(dtMerged2$Country.Name)
dt2a <- subset(dtMerged2, select=-c(Country.Code, Region, IncomeGroup, Country.Name))
dt2a <- data.frame(cbind(Year, t(dt2a)))
colnames(dt2a) <- c("Year", countryNames)
dtgrowth <- subset(dt2a, select=-c(2014))

Year <- 1961:2014
countryNames <- as.character(dtMerged3$Country.Name)
dt3a <- subset(dtMerged3, select=-c(Country.Code, Region, IncomeGroup, Country.Name))
dt3a <- data.frame(cbind(Year, t(dt3a)))
colnames(dt3a) <- c("Year", countryNames)
dtcapita <- subset(dt3a, select=-c(2014))



#Shiny server
shinyServer(function(input, output) {
    
    output$econControls <- renderUI({
        selectInput("country", label = h5("Choose countries:"), 
                    choices = economies, selected = c("Argentina","Australia"), 
                    multiple=TRUE, selectize=FALSE)
    })
    
    #Subset data given inputs
    dataOutputGDP <- reactive({
        subset(dtgdp[Year>=input$range[1] & Year<=input$range[2], ], select=c("Year", input$country))
    })
    dataOutputGrowth <- reactive({
        subset(dtgrowth[Year>=input$range[1] & Year<=input$range[2], ], select=c("Year", input$country))
    })
    dataOutputCapita<- reactive({
        subset(dtcapita[Year>=input$range[1] & Year<=input$range[2], ], select=c("Year", input$country))
    })
    
    #Compute average annual growth
    avGrowth <- reactive({
        tmp <- subset(dataOutputGrowth(), select=-Year)/100+1
        n <- nrow(tmp)
        cumul <- rep(1,length(input$country)) 
        for (i in 1:n){
            cumul <- cumul*tmp[i,]
        }
        r <- round((cumul^(1/n)-1)*100, digits=2)
        data.frame(Country=input$country, GrowthRate=as.character(r), stringsAsFactors=FALSE)
    })
    
    #Process data for plotting
    dataPlotGDP <- reactive({
        tmp <- melt(dataOutputGDP(), id.vars="Year", na.rm=FALSE)
        colnames(tmp) <- c("Year", "Country", "GDP")
        tmp
    })
    dataPlotGrowth <- reactive({
        tmp <- melt(dataOutputGrowth(), id.vars="Year", na.rm=FALSE)
        colnames(tmp) <- c("Year", "Country", "Rate")
        tmp
    })
    dataPlotCapita <- reactive({
        tmp <- melt(dataOutputCapita(), id.vars="Year", na.rm=FALSE)
        colnames(tmp) <- c("Year", "Country", "GDPcap")
        tmp
    })
    
    #Plots
    output$plot1 <- renderPlot({
        ggplot(dataPlotGDP(), aes(x=Year, y=GDP/1e9, colour=Country)) + 
            geom_line(size=1.2) + 
            labs(x="Year", y="GDP [US$b]", title="GDP (current US$)")
    })
    output$plot2 <- renderPlot({
        ggplot(dataPlotGrowth(), aes(x=Year, y=Rate, colour=Country)) + 
            geom_line(size=1.2) + 
            labs(x="Year", y="Growth rate [%]", title="GDP growth (annual %)")
    })
    output$plot3 <- renderPlot({
        ggplot(dataPlotCapita(), aes(x=Year, y=GDPcap, colour=Country)) + 
            geom_line(size=1.2) + 
            labs(x="Year", y="GDP per capita [US$]", title="GDP per capita (current US$)")
    })
    
    #Average annual growth
    output$text <- renderText({
        paste("Average annual growth [%] from",input$range[1],"to",input$range[2],":")    
    })
    output$values <- renderTable({
        avGrowth()
    })
    
    #Tables
    output$table1 <- renderDataTable({
        dataOutputGDP()
    })
    output$table2 <- renderDataTable({
        dataOutputGrowth()
    })
    output$table3 <- renderDataTable({
        dataOutputCapita()
    })
    
})
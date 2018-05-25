## app.R ##
library(shinydashboard)
#library(tidyverse)
library(DT)
library(dplyr)
library(ggplot2)

ui <- dashboardPage(
  dashboardHeader(title = "Pump It Up - Tanzania Dashboard"),
	#dashboardHeader(title = tags$a(href='http://daftpumps.com',
                                    #tags$img(src='logo.png')))  ,
## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Construction Year", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("View Data", tabName = "DataTable", icon = icon("th")),
      menuItem("Quantity by Management Type", tabName = "Tableaquantbymgmt3", icon = icon("dashboard")),
      menuItem("Regions vs Wards", tabName = "TableaRegionsvsWards", icon = icon("dashboard")),
      menuItem("Pump Age Map", tabName = "Tableaage", icon = icon("map")),
      menuItem("Water Quantity Map", tabName = "Tableawaterquant", icon = icon("map")),
      menuItem("Water Quantity Map 2", tabName = "Tableawaterquant2", icon = icon("map")),
      menuItem("LGAs", tabName = "LGAs", icon = icon("map")),
      menuItem("Basin", tabName = "Tableabasin", icon = icon("map"))
    )
  ),
  ## Body content
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              fluidRow(
                box(plotOutput("plot1", height = 500))
		),
                
              fluidRow(
                box(
                  title = "Controls",
                  sliderInput("slider", "Number of observations:", 5, 100, 50)
                )
              )
      ),
     tabItem(tabName = "DataTable",
              fluidRow(column(
                4,
                selectInput(
                  "status_group",
                  "Status Group:",
                  c("All",
                    "non functional",
                    "functional",
                    "functional needs repair")
                )
              )),
              # Create a new row for the table.
              fluidRow(DT::dataTableOutput("train_table"))), 
      # Second tab content
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      ),
      tabItem(
                tabName = "Tableaquantbymgmt3",
                fluidRow(
                    tags$iframe(
			src = "https://public.tableau.com/views/Tanzania_5/QuantitybyManagementTypeandPopulation3?:showVizHome=no&:embed=true",
                        #height = 800, width = "90%"
                        #height = 800, width = "95%", align="middle"
                        height = 800, width = "95%", align="middle"
                    )
                )
      ),
      tabItem(
                tabName = "Tableawaterquant2",
                fluidRow(
                    tags$iframe(
			src = "https://public.tableau.com/views/Tanzania_5/WaterQuantity2?:showVizHome=no&:embed=true",
                        #height = 800, width = "90%"
                        height = 800, width = "95%", align="middle"
                    )
                )
      ),
      tabItem(
                tabName = "LGAs",
                fluidRow(
                    tags$iframe(
			src = "https://public.tableau.com/views/Tanzania_5/LGAs?:showVizHome=no&:embed=true",
                        #height = 800, width = "90%"
                        height = 800, width = "95%", align="middle"
                    )
                )
      ),
      tabItem(
                tabName = "TableaRegionsvsWards",
                fluidRow(
                    tags$iframe(
			src = "https://public.tableau.com/views/Tanzania_5/RegionsvsWards?:showVizHome=no&:embed=true",
                        #height = 800, width = "90%"
                        height = 800, width = "95%", align="middle"
                    )
                )
      ),
      tabItem(
                tabName = "Tableabasin",
                fluidRow(
                    tags$iframe(
			src = "https://public.tableau.com/views/Tanzania_5/Basin?:showVizHome=no&:embed=true",
                        #height = 800, width = "90%"
                        height = 800, width = "95%", align="middle"
                    )
                )
      ),
      tabItem(
                tabName = "Tableawaterquant",
                fluidRow(
                    tags$iframe(
			src = "https://public.tableau.com/views/Tanzania_5/WaterQuantity?:showVizHome=no&:embed=true",
                        #height = 800, width = "90%"
                        height = 800, width = "95%", align="middle"
                    )
                )
      ),
      tabItem(
                tabName = "Tableaage",
                fluidRow(
                    tags$iframe(
			src = "https://public.tableau.com/views/Tanzania_5/Age?:showVizHome=no&:embed=true",
                        height = 800, width = "95%", align="middle"
                    )
                )
      )
    )
  )
)

server <- function(input, output) {
  
data_x <-
    read.csv(
      "/srv/shiny-server/data/tanzania-X-train.csv"
    )
  data_y <-
    read.csv(
      "/srv/shiny-server/data/tanzania-y-train.csv"
    )
  data <- merge(data_x, data_y, on = "id")

  output$plot1 <- renderPlot({
    ggplot(data[data$construction_year>0,], aes(construction_year, fill = status_group)) + geom_histogram(
      alpha = 0.5,
      aes(y = ..density..),
      bins = input$slider
      ,
      position = 'identity'
      #position = 'dodge'
    )
  })
	output$train_table <- DT::renderDataTable(DT::datatable({
	    if (input$status_group != "All") {
	      data <- data[data$status_group == input$status_group,]
	    }
	    
	    data
	  }))


}

shinyApp(ui, server)

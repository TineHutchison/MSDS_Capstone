## app.R ##
library(shinydashboard)

ui <- dashboardPage(
  #dashboardHeader(title = "Pump It Up - Tanzania Dashboard"),
  dashboardHeader(title = "Pump It Up - Tanzania Dashboard"),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Test Tab", tabName = "widgets", icon = icon("th")),
      menuItem("Pump Age Map", tabName = "Tableaage", icon = icon("dashboard")),
      menuItem("Quantity by Management Type and Population", tabName = "Tableaquantbymgmt3", icon = icon("dashboard")),
      menuItem("Water Quantity Map", tabName = "Tableawaterquant2", icon = icon("dashboard")),
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
    )
  ),
  ## Body content
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              fluidRow(
                box(plotOutput("plot1", height = 250)),
                
                box(
                  title = "Controls",
                  sliderInput("slider", "Number of observations:", 1, 100, 50)
                )
              )
      ),
      
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
                        height = 600, width = "90%", align="middle"
                    )
                )
      ),
      tabItem(
                tabName = "Tableawaterquant2",
                fluidRow(
                    tags$iframe(
			src = "https://public.tableau.com/views/Tanzania_5/WaterQuantity2?:showVizHome=no&:embed=true",
                        #height = 800, width = "90%"
                        height = 600, width = "90%", align="middle"
                    )
                )
      ),
      tabItem(
                tabName = "Tableaage",
                fluidRow(
                    tags$iframe(
			src = "https://public.tableau.com/views/Tanzania_5/Age?:showVizHome=no&:embed=true",
                        height = 600, width = "90%", align="middle"
                    )
                )
      )
    )
  )
)

server <- function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}

shinyApp(ui, server)

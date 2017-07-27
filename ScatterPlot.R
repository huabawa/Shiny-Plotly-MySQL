library(shiny)
library(RMySQL)
library(plotly)

ui <- fluidPage(
  plotlyOutput("plot"),
  verbatimTextOutput("event")
)

server <- function(input, output) {
  library(RMySQL)
  library(plotly)
  options(mysql = list(
    "host" = "", #endpoint from RDS MYSQl instance OR IP: 127.0.0.1
    "port" = 3306, #Default port is 3306
    "user" = "root", #root unless changed
    "password" = "" 
  ))
  DB_NAME <- "" #MySQL database name
  TABLE_NAME <- "" #MySQL table name
  
  save_data_mysql <- function(data) {
    db <- dbConnect(MySQL(), dbname = DB_NAME,
                    host = options()$mysql$host,
                    port = options()$mysql$port,
                    user = options()$mysql$user,
                    password = options()$mysql$password)
    query <-
      sprintf("INSERT INTO %s (%s) VALUES ('%s')",
              TABLE_NAME,
              paste(names(data), collapse = ", "),
              paste(data, collapse = "', '")
      )
    dbGetQuery(db, query)
    dbDisconnect(db)
  }
  load_data_mysql <- function() {
    db <- dbConnect(MySQL(), dbname = DB_NAME,
                    host = options()$mysql$host,
                    port = options()$mysql$port,
                    user = options()$mysql$user,
                    password = options()$mysql$password)
    query <- sprintf("SELECT * FROM %s", TABLE_NAME)
    data <- dbGetQuery(db, query)
    dbDisconnect(db)
    
    data
  }
  
  
  # renderPlotly() also understands ggplot2 objects!
  output$plot <- renderPlotly({
    plot_ly(data, x = ~date, y = ~price, type = "scatter")
  })
  
  output$event <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) "Hover on a point!" else d
  })
}

shinyApp(ui, server)


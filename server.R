library(shiny)
library(shinydashboard)

shinyServer(function(input, output) {

    output$kpi_orders <- renderText({
        25
    })
    
    output$kpi_sales <- renderText({
        25
    })
    
    output$kpi_profit <- renderText({
        25
    })
    
    output$kpi_margin <- renderText({
        25
    })
    
    output$kpi_plot <- renderPlot({
        plot(mtcars$disp, mtcars$cyl)
    })
    
})

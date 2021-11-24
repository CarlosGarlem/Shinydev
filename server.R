library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)


shinyServer(function(input, output, session) {
    
    
    kpi_choosen_metric <- eventReactive(input$kpi_metric, {
        
        df <- store_df %>%
            filter(Order.Date >= input$kpi_date_range[1], 
                   Order.Date <= input$kpi_date_range[2])
        
        if(input$kpi_metric == 'Margin'){
            df <- df %>%
                    group_by(Order.Date) %>%
                    summarise(Metric = (sum(Profit)/sum(Sales))*100)
            
            ylab <- 'Margin (%)'
            title <- 'Profit Margin'
        } else if (input$kpi_metric == 'Profit'){
            df <- df %>%
                    group_by(Order.Date) %>%
                    summarise(Metric = sum(Profit))
            
            ylab <- 'Profit ($)'
            title <- 'Profit'
                    
        } else if (input$kpi_metric == 'Sales'){
            df <- df %>%
                group_by(Order.Date) %>%
                summarise(Metric = sum(Sales))
            
            ylab <- 'Sales ($)'
            title <- 'Sales'
            
        } else if (input$kpi_metric == 'Orders'){
            df <- df %>%
                group_by(Order.Date) %>%
                summarise(Metric = n_distinct(Order.ID))
            
            ylab <- 'Orders'
            title <- 'Orders'
            
        }
        
        metric_list <- list('data' = df, 'ylab' = ylab, 'title' = title)
    }, ignoreNULL = T)
    

    output$kpi_orders <- renderText({
        orders <- store_df %>%
                    filter(Order.Date >= input$kpi_date_range[1], 
                           Order.Date <= input$kpi_date_range[2]) %>%
                    summarise(n_distinct(Order.ID))
        orders[1,1]
    })
    
    
    output$kpi_sales <- renderText({
        sales <- store_df %>%
                    filter(Order.Date >= input$kpi_date_range[1], 
                        Order.Date <= input$kpi_date_range[2]) %>%
                    summarise(sum(Sales))
        
        paste('$', format(sales[1,1], nsmall = 2, decimal.mark = '.', big.mark = ','), sep = '')
    })
    
    
    output$kpi_profit <- renderText({
        profit <- store_df %>%
                    filter(Order.Date >= input$kpi_date_range[1], 
                        Order.Date <= input$kpi_date_range[2]) %>%
                    summarise(sum(Profit))
        
        paste('$', format(profit[1,1], nsmall = 2, decimal.mark = '.', big.mark = ','), sep = '')
    })
    
    
    output$kpi_margin <- renderText({
        results <- store_df %>%
                    filter(Order.Date >= input$kpi_date_range[1], 
                        Order.Date <= input$kpi_date_range[2]) %>%
                    summarise(Profit = sum(Profit), Sales = sum(Sales))
        
        margin <- (results$Profit / results$Sales) * 100
        paste(format(margin, digits = 2, nsmall = 2), '%', sep = '')
    })
    
    
    output$kpi_plot <- renderPlot({
        
        list_metric <- kpi_choosen_metric()
        ggplot(list_metric$data, aes(x = Order.Date, y = Metric)) +
            geom_line(size = 1.2, color = 'steelblue3') + 
            geom_point(size = 2, color = 'steelblue3') +
            theme_minimal() +
            ylab(list_metric$ylab) + 
            ggtitle(list_metric$title) + 
            theme(plot.title = element_text(size = 15, face = 'bold'))
        # ggplot(aes(x = Order.Date)) +
        #     geom_line(aes(y = Profit), size = 1, color = 'orange') +
        #     geom_line(aes(y = Sales), size = 1, color = 'blue') +
        #     scale_y_continuous(
        #         name = 'Profit ($)', # Features of the first axis
        #         sec.axis = sec_axis(trans = ~.*100, name = 'Sales ($)') # Add a second axis and specify its features
        #     ) + 
        #     theme_minimal()
        
    })
    
})



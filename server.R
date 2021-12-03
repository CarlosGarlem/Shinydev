library(shiny)
library(ggplot2)


shinyServer(function(input, output, session) {
    
    #KPIs------------------------------------------------------------------------------------------------------------
    
    kpi_choosen_metric <- reactive({
        
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
            title <- 'Profit Amount'
                    
        } else if (input$kpi_metric == 'Sales'){
            df <- df %>%
                group_by(Order.Date) %>%
                summarise(Metric = sum(Sales))
            
            ylab <- 'Sales ($)'
            title <- 'Sales Amount'
            
        } else if (input$kpi_metric == 'Orders'){
            df <- df %>%
                group_by(Order.Date) %>%
                summarise(Metric = n_distinct(Order.ID))
            
            ylab <- 'Sales'
            title <- 'Sales'
            
        }
        
        metric_list <- list('data' = df, 'ylab' = ylab, 'title' = title)
    })
    

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
        
    })
    
    
    
    #Regions------------------------------------------------------------------------------------------------------------
    
    observeEvent(input$region_viz, {
        updateTabsetPanel(session, 'region_tab', selected = input$region_viz)
    })
    
    
    observeEvent(input$region_chk_regions, {
        choices_df <- store_df %>%
                        filter(Region %in% input$region_chk_regions) %>%
                        distinct(State)
        
        updateSelectInput(session, 'region_state', selected = choices_df$State, choices = choices_df$State)
    })
    
    
    output$region_map <- renderPlotly({
        
        state_df <- store_df %>%
                    filter(Order.Date >= input$region_date_range[1], 
                            Order.Date <= input$region_date_range[2],
                            Region %in% input$region_chk_regions,
                            State %in% input$region_state) %>%
                            group_by(State, StateAbb) %>%
                            summarise(Sales = n_distinct(Order.ID))
        
        g <- list(
            scope = 'usa',
            projection = list(type = 'albers usa'),
            lakecolor = toRGB('white')
        )
        
        plot_geo(state_df) %>%
            add_trace(
                z = ~Sales, 
                text = state_df$State,
                span = I(0),
                locations = state_df$StateAbb,
                locationmode = 'USA-states') %>%
            layout(geo = g)
        
    })
    
    
    output$region_bars <- renderPlot({
        store_df %>%
            filter(Order.Date >= input$region_date_range[1], 
                   Order.Date <= input$region_date_range[2],
                   Region %in% input$region_chk_regions,
                   State %in% input$region_state) %>%
            group_by(Region, State) %>%
            summarise(Sales = n_distinct(Order.ID)) %>%
            ggplot(aes(x = State, y = Sales, fill = Region)) + 
                geom_bar(stat = 'identity')+
                geom_text(aes(label = Sales), vjust = -0.3, size = 3.5)+
                theme_minimal() +
                ggtitle('Sales by State and Region') + 
                theme(axis.text.x = element_text(angle = 70)) +
                theme(plot.title = element_text(size = 15, face = 'bold'))
            
    })
})



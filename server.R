library(shiny)


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
    
    
    # Products --------------------------------------------------------------------------------------------------------


    observeEvent(input$prod_cat, {
        choices_df <- store_df %>%
            filter(Category %in% input$prod_cat) %>%
            distinct(Sub.Category)
        
        updateSelectInput(session, 'prod_subcat', selected = choices_df$Sub.Category, choices = choices_df$Sub.Category)
    })
    
    
    prod_profit_filters <- reactive({
        df <- store_df %>% filter(Category %in% input$prod_cat, 
                                  Sub.Category %in% input$prod_subcat, 
                                  Segment %in% input$prod_segment,
                                  Order.Date >= input$prod_date_range[1],
                                  Order.Date <= input$prod_date_range[2],
                                  Profit >= input$prod_profit[1],
                                  Profit <= input$prod_profit[2])
        
        xlab <- 'Profit'
        ylab <- 'Quantity'
        
        metric_list <- list('data' = df, 'ylab' = ylab, 'title' = title)
        metric_list
    })
    
    
    output$prod_profit <- renderPlot({
        filtered_data <- prod_profit_filters()
        
        ggplot(filtered_data$data, aes(y = Profit, x = Order.Date, size=Quantity, color=Segment)) +
            geom_point()
    })
    
    
    output$prod_segment_graf <- renderPlot({
        filtered_data <- prod_profit_filters() 
        filtered_data$data %>% 
            group_by(Segment) %>%
            summarise(ProfitBySegment = sum(Profit)) %>%
            ggplot(aes(y = ProfitBySegment, x = Segment, fill = Segment)) +
            geom_col()
        
        
    })
    
    
    output$prod_tbl <- DT::renderDataTable({
        df <- prod_profit_filters()$data
        clicked <- row.names(nearPoints(df, input$clk))
        brushed <- row.names(brushedPoints(df, input$mouse_brush))
        isolate({
            if((length(clicked) + length(brushed)) > 0){
                df <- df %>%
                    filter(row.names(df) %in% c(clicked, brushed))
            }
        })
        
        datatable(df %>% select(-c(Row.ID, Customer.Name, Postal.Code, StateAbb)), rownames= FALSE)

    })
    
    # Shipping --------------------------------------------------------------------------------------------------------
    
    ship_filters <- reactive({
        df <- store_df %>% filter(Ship.Mode %in% input$ship_mode, 
                                  Segment %in% input$ship_segment,
                                  Ship.Date >= input$ship_date_range[1],
                                  Ship.Date <= input$ship_date_range[2])
        
        metric_list <- list('data' = df)
        metric_list
    })
    
    
    output$ship_plot <- renderPlotly({
        filtered_data <- ship_filters()
        plt <- filtered_data$data %>% 
            group_by(Segment, Ship.Mode) %>%
            summarise(n = n()) %>%
            ggplot(aes(weight = n, fill = Ship.Mode, x = Segment)) + 
            geom_bar(position="dodge") 
        plotly_build(plt)
    })
    
    
    

    # URL Query Parmas ---------------------------------------------------------

    observe({
        query <- parseQueryString(session$clientData$url_search)
        view <- query[["view"]]
        if(!is.null(view)){
            updateNavbarPage(session, 'nav', selected = view)
        }
    })
})



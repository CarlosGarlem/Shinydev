library(shiny)
library(lubridate)


shinyUI(navbarPage(title = 'Store Analysis',
                   
   tabPanel('KPIs',
        sidebarLayout(position = 'right',
            sidebarPanel(
                dateRangeInput('kpi_date_range', 'Date Range', start = floor_date( max(store_df$Order.Date), 'year')
                               ,end = max(store_df$Order.Date)),
                selectInput('kpi_metric'
                            ,'Metric to plot'
                            ,choices = c('Orders', 'Sales', 'Profit', 'Margin')
                            ,selected = 'Margin')
            ),
            mainPanel(
                h2('Store KPIs', align = 'center', style = 'font-weight: bold'),
                br(),
                br(),
                fluidRow(
                    column(3,
                           div(
                               h5('Total Orders', align = 'center', style = 'font-weight: bold'),
                               h4(textOutput('kpi_orders'), align = 'center', style = 'color:blue; font-weight: bold'),
                           )  
                    ),
                    column(3,
                           div(
                               h5('Sales Amount', align = 'center', style = 'font-weight: bold'),
                               h4(textOutput('kpi_sales'), align = 'center', style = 'color:blue; font-weight: bold'),
                           )  
                    ),
                    column(3,
                           div(
                               h5('Profit Amount', align = 'center', style = 'font-weight: bold'),
                               h4(textOutput('kpi_profit'), align = 'center', style = 'color:blue; font-weight: bold'),
                           )  
                    ),
                    column(3,
                           div(
                               h5('Margin %', align = 'center', style = 'font-weight: bold'),
                               h4(textOutput('kpi_margin'), align = 'center', style = 'color:blue; font-weight: bold'),
                           )  
                    )
                ),
                br(),
                br(),
                fluidRow(plotOutput('kpi_plot'))
            )
                    
        )
    ),
   
   
   tabPanel('Regions'),
   tabPanel('Products'),
   tabPanel('Shipping')

))

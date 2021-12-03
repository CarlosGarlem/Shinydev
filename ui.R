library(shiny)

shinyUI(navbarPage(title = 'Store Analysis',
                   
   tabPanel('KPIs',
     sidebarLayout(position = 'right',
      sidebarPanel(
          dateRangeInput('kpi_date_range', 'Date Range', start = floor_date(max(store_df$Order.Date), 'year')
                         ,end = max(store_df$Order.Date)),
          selectInput('kpi_metric'
                      ,'Metric to plot'
                      ,choices = c('Sales' = 'Orders',
                                   'Sales Amount' = 'Sales',
                                   'Profit Amount' = 'Profit',
                                   'Margin' = 'Margin')
                      ,selected = 'Orders')
      ),
      mainPanel(
          h2('Store KPIs', align = 'center', style = 'font-weight: bold'),
          br(),
          br(),
          fluidRow(
              column(3,
                     div(
                         h5('Total Sales', align = 'center', style = 'font-weight: bold'),
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
   
   
   
   tabPanel('Regions',
      sidebarLayout(position = 'right',
        sidebarPanel(
           dateRangeInput('region_date_range', 'Date Range', start = floor_date(max(store_df$Order.Date), 'year')
                          ,end = max(store_df$Order.Date)),
           selectInput('region_viz'
                       ,'Choose visualization'
                       ,choices = c('Map', 'Bars')
                       ,selected = 'Map'),
           checkboxGroupInput('region_chk_regions'
                              ,'Choose regions'
                              ,choices = unique(store_df$Region)
                              ,selected = 'Central'),
           selectInput('region_state',
                       'Choose state',
                       choices = unique(store_df$State),
                       multiple = T)
        ),
        mainPanel(
           h2('Sales by Region & State', align = 'center', style = 'font-weight: bold'),
           br(),
           br(),
           br(),
           tabsetPanel(id = 'region_tab', type = 'hidden',
                       tabPanel('Map', plotlyOutput('region_map')),
                       tabPanel('Bars', plotOutput('region_bars'))
           ),
        )
      )
   ),
   
   tabPanel('Products'),
   tabPanel('Shipping')

))

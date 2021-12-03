library(shiny)
library(dplyr)
library(ggplot2)
library(DT)

shinyUI(navbarPage(id='nav', title = 'Store Analysis',
                   
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
   
   tabPanel('Products',
            h2('Products Dashboard'),
            sidebarLayout(
               sidebarPanel(
                  selectInput('prod_cat', 'Choose Category', choices=unique(store_df$Category), multiple = T, selected=unique(store_df$Category)),
                  selectInput('prod_subcat', 'Choose Sub Category', choices=unique(store_df$Sub.Category), multiple = T),
                  selectInput('prod_segment', 'Choose Segment', choices=unique(store_df$Segment), multiple = T, selected=unique(store_df$Segment)),
                  dateRangeInput('prod_date_range', 'Date Range', start = floor_date(max(store_df$Order.Date), 'year')
                                 ,end = max(store_df$Order.Date)),
                  sliderInput('prod_profit', 'Profit', min=min(store_df$Profit), max = max(store_df$Profit), value = c(0,max(store_df$Profit))),
                  width = 2
                  ),
               mainPanel(
                  fluidRow(
                     column(6 , 
                            plotOutput('prod_profit', 
                                       click='clk',
                                       brush = brushOpts(id = 'mouse_brush',
                                                         direction = c("x"))), 
                            plotOutput('prod_segment_graf')),
                     column(6, DT::dataTableOutput('prod_tbl')))), 
                  position="left", fluid=T)),
   tabPanel('Shipping', 
            h2('Shipping Dashboard'), 
            sidebarLayout(
               sidebarPanel(
                  selectInput('ship_mode', 'Choose Mode', choices=unique(store_df$Ship.Mode), multiple = T, selected=unique(store_df$Ship.Mode)),
                  selectInput('ship_segment', 'Choose Segment', choices=unique(store_df$Segment), multiple = T, selected = unique(store_df$Segment)),
                  dateRangeInput('ship_date_range', 'Date Range', start = floor_date(max(store_df$Ship.Date), 'year')
                                 ,end = max(store_df$Ship.Date))
               ),
               mainPanel(
                  plotlyOutput('ship_plot')
               ))
            )

))

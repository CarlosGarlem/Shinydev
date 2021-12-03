# Shiny Project
This project contains a shiny app developed based on Sample-SuperStore dataset, which is based on retail orders.
Feel free to access live app at: https://garlemdev.shinyapps.io/StoreAnalysis/?view=KPIs

### Structure
Repository contains mainly 3 files. 
**1. server.R**. Backend logic of the program
**2. ui.R**. Frontend logic of the program
**3. Global.R**. Contains the shared global variables between Server and UI

**Components**
- **Tables**. Applied using DT package, available under *Products* tab
- **Graphs**. Available through the entire project, applying both ggplot2 and plotly packages
- **Input**. With a variaty of inputs from select, date range, check box, and sliders
- **Layouts**. Based on sidebar layout as well as applying navbar page style
- **Interactivity**. Available under *Products* tab when clicking or brushing points on the scatter plot to filter the table values
- **Reactivity**. Applied through reactive functions and observe events on the backend code
- **Update Functions**. Apply over select filters to created only relevant values effect, as well as over tabset panel and navbar. 
- **URL params**. Feel free to start the project on any view, by applying query as: "?view=<view>" values available are tabs names: KPIs, Regions, Products, Shipping.
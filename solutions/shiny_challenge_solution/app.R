library(shiny)
library(gapminder)
library(tidyverse)
library(DT)

ui <- fluidPage(
  titlePanel("Gapminder: Life expectancy over time"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "continent",
        "Continent:",
        choices = unique(gapminder$continent),
        selected = unique(gapminder$continent)
      ),
      sliderInput(
        "year",
        "Year range:",
        min = 1952,
        max = 2007,
        value = c(1952, 2007),
        sep = ""
      )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("plot")),
        tabPanel("Data", DTOutput("table"))
      )
    )
  )
)

server <- function(input, output) {
  gapminder_filtered <- reactive({
    req(input$continent)
    gapminder %>%
      filter(
        continent %in% input$continent,
        year >= input$year[1],
        year <= input$year[2],
      )
  })

  output$plot <- renderPlot({
    ggplot(
      gapminder_filtered(),
      aes(year, lifeExp, col = country, group = country)
    ) +
      geom_line() +
      facet_wrap(vars(continent)) +
      theme_minimal() +
      theme(legend.position = "none")
  })

  output$table <- renderDataTable({
    datatable(gapminder_filtered())
  })
}

# Run the application
shinyApp(ui = ui, server = server)

library(shiny)
library(ggplot2)
library(DT)
library(stringr)
library(dplyr)
library(tools)
load("movies.Rdata")

# Define UI for application that plots features of movies -----------
ui <- fluidPage(

  # Application title -----------------------------------------------
  titlePanel("Movie browser"),

  # Sidebar layout with a input and output definitions --------------
  sidebarLayout(

    # Inputs: Select variables to plot ------------------------------
    sidebarPanel(

      # Select variable for y-axis ----------------------------------
      selectInput(inputId = "y",
                  label = "Y-axis:",
                  choices = c("IMDB rating" = "imdb_rating",
                              "IMDB number of votes" = "imdb_num_votes",
                              "Critics Score" = "critics_score",
                              "Audience Score" = "audience_score",
                              "Runtime" = "runtime"),
                  selected = "audience_score"),

      # Select variable for x-axis ----------------------------------
      selectInput(inputId = "x",
                  label = "X-axis:",
                  choices = c("IMDB rating" = "imdb_rating",
                              "IMDB number of votes" = "imdb_num_votes",
                              "Critics Score" = "critics_score",
                              "Audience Score" = "audience_score",
                              "Runtime" = "runtime"),
                  selected = "critics_score"),

      # Select variable for color -----------------------------------
      selectInput(inputId = "z",
                  label = "Color by:",
                  choices = c("Title Type" = "title_type",
                              "Genre" = "genre",
                              "MPAA Rating" = "mpaa_rating",
                              "Critics Rating" = "critics_rating",
                              "Audience Rating" = "audience_rating"),
                  selected = "mpaa_rating"),

      # Set alpha level ---------------------------------------------
      sliderInput(inputId = "alpha",
                  label = "Alpha:",
                  min = 0, max = 1,
                  value = 0.5),

      # Set point size ----------------------------------------------
      sliderInput(inputId = "size",
                  label = "Size:",
                  min = 0, max = 5,
                  value = 2),

      # Show data table ---------------------------------------------
      checkboxInput(inputId = "show_data",
                    label = "Show data table",
                    value = TRUE),

      # Enter text for plot title ---------------------------------------------
      textInput(inputId = "plot_title",
                label = "Plot title",
                placeholder = "Enter text to be used as plot title"),

      # Horizontal line for visual separation -----------------------
      hr(),

      # Select which types of movies to plot ------------------------
      checkboxGroupInput(inputId = "selected_type",
                         label = "Select movie type(s):",
                         choices = c("Documentary", "Feature Film", "TV Movie"),
                         selected = "Feature Film"),

      # Select sample size ----------------------------------------------------
      numericInput(inputId = "n_samp",
                   label = "Sample size:",
                   min = 1, max = nrow(movies),
                   value = 50),

      # Get a new sample ------------------------------------------------------
      actionButton(inputId = "get_new_sample",
                   label = "Get new sample"),

      # A little bit of visual separation -------------------------------------
      br(), br(),

      # Write sampled data as csv ------------------------------------------
      actionButton(inputId = "write_csv",
                   label = "Write CSV")

    ),

    # Output: -------------------------------------------------------
    mainPanel(

      # Print how long app is being viewed for ----------------------
      textOutput(outputId = "time_elapsed"),
      br(),

      # Show scatterplot --------------------------------------------
      plotOutput(outputId = "scatterplot"),
      br(),          # a little bit of visual separation

      # Print number of obs plotted ---------------------------------
      uiOutput(outputId = "n"),
      br(), br(),    # a little bit of visual separation

      # Show data table ---------------------------------------------
      DT::dataTableOutput(outputId = "moviestable")
    )
  )
)

# Define server function required to create the scatterplot ---------
server <- function(input, output, session) {

  # Create a subset of data filtering for selected title types ------
  movies_subset <- reactive({
    req(input$selected_type) # ensure availablity of value before proceeding
    filter(movies, title_type %in% input$selected_type)
  })

  # Update the maximum allowed n_samp for selected type movies ------
  observe({
    updateNumericInput(session,
                       inputId = "n_samp",
                       value = min(50, nrow(movies_subset())),
                       max = nrow(movies_subset())
    )
  })

  # Get new sample --------------------------------------------------
  movies_sample <- eventReactive(eventExpr = input$get_new_sample,
                                 valueExpr = {
                                   req(input$n_samp)
                                   sample_n(movies_subset(), input$n_samp)
                                   },
                                 ignoreNULL = FALSE
  )

  # Convert plot_title str_to_title ----------------------------------
  pretty_plot_title <- reactive({ str_to_title(input$plot_title) })

  # Create scatterplot object the plotOutput function is expecting --
  output$scatterplot <- renderPlot({
    ggplot(data = movies_sample(), aes_string(x = input$x, y = input$y,
                                              color = input$z)) +
      geom_point(alpha = input$alpha, size = input$size) +
      labs(x = str_to_title(str_replace_all(input$x, "_", " ")),
           y = str_to_title(str_replace_all(input$y, "_", " ")),
           color = str_to_title(str_replace_all(input$z, "_", " ")),
           title = isolate({ pretty_plot_title() })
      )
  })

  # Print number of movies plotted ----------------------------------
  output$n <- renderUI({
    types <- movies_sample()$title_type |>
      factor(levels = input$selected_type)
    counts <- table(types)

    HTML(paste("There are", counts, input$selected_type, "movies in this dataset. <br>"))
  })

  # Print data table if checked -------------------------------------
  output$moviestable <- DT::renderDataTable(
    if(input$show_data){
      DT::datatable(data = movies_sample()[, 1:7],
                    options = list(pageLength = 10),
                    rownames = FALSE)
    }
  )

  # Write sampled data as csv ---------------------------------------
  observeEvent(eventExpr = input$write_csv,
               handlerExpr = {
                 filename <- paste0("movies_", str_replace_all(Sys.time(), ":|\ ", "_"), ".csv")
                 write.csv(movies_sample(), file = filename, row.names = FALSE)
                 }
  )

  # Calculate time diff bet when app is first launched and now ------
  beg <- Sys.time()
  now <- reactive({ invalidateLater(millis = 1000); Sys.time() })
  diff <- reactive({ round(difftime(now(), beg, units = "secs")) })

  # Print time viewing app ------------------------------------------
  output$time_elapsed <- renderText({
    paste("You have been viewing this app for", diff(), "seconds.")
  })

}

# Run the app -------------------------------------------------------
shinyApp(ui = ui, server = server)

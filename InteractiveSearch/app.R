#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(reticulate)
library(gt)
use_condaenv("r-reticulate")
# py_install("requests", pip = TRUE)
# py_install("fake_useragent", pip = TRUE)
# py_install("bs4", pip = TRUE)
# py_install("nltk", pip = TRUE)
source_python('~/box-sync/2021-important/info-ret/CS6501-Information-Retrieval-Project/issue_query.py')
source_python('~/box-sync/2021-important/info-ret/CS6501-Information-Retrieval-Project/tokenize.py')
source_python('~/box-sync/2021-important/info-ret/CS6501-Information-Retrieval-Project/bag_of_word.py')
source_python('~/box-sync/2021-important/info-ret/CS6501-Information-Retrieval-Project/clarify.py')

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Internet Search (with Interactive Disambiguation)"),

    mainPanel(
       textInput("query", ""),
       actionButton("search", "Search!"),
       checkboxGroupInput("categories", "", NULL, width = "750px"),
       tableOutput("results")
    )
)

server <- function(input, output, session) {

    getCats <- eventReactive(input$search, {
        query <- input$query
        fetch_results <- issue_query(query)
        bow <- bag_of_word(query, fetch_results[[3]])
        categories <- clarify(bow)
        categories
    })
    
    results <- eventReactive(input$search, {
        query <- input$query
        fetch_results <- issue_query(query)
        title_links <- paste0("<a href='",
                              fetch_results[[1]],
                              "' target='_blank'>",
                              fetch_results[[2]],
                              "</a>")
        tibble(" " = title_links,
               "  " = fetch_results[[3]])
    })
    
    observe({
        updateCheckboxGroupInput(session, "categories",
                                 choices = getCats(),
                                 inline = TRUE)
    })
        
    output$results <- renderTable({
        results()
    }, sanitize.text.function = function(x) x, width = "750px")
    
}

# Run the application 
shinyApp(ui = ui, server = server)

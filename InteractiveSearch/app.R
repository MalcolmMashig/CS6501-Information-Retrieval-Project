#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(reticulate)
# conda_create(envname = "python")
# conda_install("python", packages = c("requests", "bs4", "nltk"))
# use_condaenv(condaenv = "python", required = TRUE)
use_python("python")
library(shiny)
library(tidyverse)
library(gt)
# library(qdap)
# library(tm)
library(stringi)
library(tidytext)
# use_condaenv()
py_install("requests", pip = TRUE)
py_install("fake_useragent", pip = TRUE)
py_install("bs4", pip = TRUE)
py_install("nltk", pip = TRUE)
source_python('get_results.py')
source_python(here::here('InteractiveSearch', 'get_results.py'))
source_python(here::here('InteractiveSearch', 'tokenize.py'))
source_python(here::here('InteractiveSearch', 'bag_of_word.py'))
source_python(here::here('InteractiveSearch', 'clarify.py'))

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Internet Search (with Interactive Disambiguation)"),

    mainPanel(
       textInput("query", ""),
       checkboxGroupInput("categories", "", NULL, width = "750px"),
       actionButton("search", "Search"),
       tableOutput("results")
    )
)

server <- function(input, output, session) {

    getCats <- eventReactive(input$search, {
        query <- input$query
        results <- get_results(query)
        original_ranking <- tibble(
            ranking = 1:length(results[[1]]),
            url = results[[1]],
            title = results[[2]],
            caption = results[[3]]
        )
        
        # tokenize results -------------
        
        query_tokens <- tibble(row = 1, query = query) %>% 
            unnest_tokens(word, query) %>% 
            pull(word)
        
        original_ranking %>% 
            select(ranking, title) %>% 
            unnest_tokens(word, title, token = "skip_ngrams") %>% 
            filter(
                !(word %>% 
                      str_detect(str_c("(", paste(query_tokens, collapse = ')|('), ")"))),
                # !(word %in% tm::stopwords('en')),
                !(
                    word %>%
                        str_detect(
                            str_c("(", paste(tm::stopwords('en'), collapse = ')|('), ")")
                        )
                ),
                word != ""
            ) %>% 
            # distinct(ranking, word) %>%  # document freq
            count(word, sort = TRUE) %>% 
            head(2) %>% 
            pull(word)
    })
    
    display_results <- eventReactive(input$search, {
        query <- input$query
        results <- get_results(query)
        title_links <- paste0("<a href='",
                              results[[1]],
                              "' target='_blank'>",
                              results[[2]],
                              "</a>")
        tibble(" " = title_links,
               "  " = results[[3]])
    })
    
    observe({
        updateCheckboxGroupInput(session, "categories",
                                 choices = getCats(),
                                 inline = TRUE)
    })
        
    output$results <- renderTable({
        display_results()
    }, sanitize.text.function = function(x) x, width = "750px")
    
}

# Run the application 
shinyApp(ui = ui, server = server)

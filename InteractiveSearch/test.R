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
py_install("sklearn", pip = TRUE)
# source_python('get_results.py')

source_python(here::here('InteractiveSearch', 'tokenize.py'))
source_python(here::here('InteractiveSearch', 'bag_of_word.py'))
source_python(here::here('InteractiveSearch', 'clarify.py'))

test()


# pipeline.R

library(tidyverse)
library(reticulate)
library(tidytext)
# library(qdap)
# library(tm)

reticulate::source_python("get_results.py")

query <- "columbia"

# get results -----------

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
  select(ranking, caption) %>% 
  unnest_tokens(word, caption, token = "skip_ngrams") %>%
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
  mutate(
    n = (n - mean(n)) / sd(n)
  ) %>% 
  filter(
    n > 3
  )
                      




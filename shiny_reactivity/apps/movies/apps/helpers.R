# Function for prettifying axis labels
prettify_label <- function(x) {
  x %>%
    str_replace_all("_", " ") %>%
    str_to_title() %>%
    str_replace("Imdb", "IMDB") %>%
    str_replace("Mpaa", "MPAA")
}

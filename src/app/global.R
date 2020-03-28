library(shiny)
library(shiny.grid)
library(shiny.blank)
library(htmltools)
library(tidyr)
library(leaflet)
library(R6)
library(googlesheets)
library(glue)
library(utils)
library(dplyr)
library(jsonlite)
library(modules)
library(sass)

# Process and minify styles
sass(
  sass::sass_file("styles/main.scss"),
  cache_options = sass_cache_options(FALSE),
  options = sass_options(output_style = "compressed"),
  output = "www/styles/sass.min.css"
)

swipeCards <- use("components/swipe-cards.R")

gameManager <- use("logic/gameManager.R")$gameManager$new()

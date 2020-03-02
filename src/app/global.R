library(shiny)
library(shiny.grid)
library(shiny.blank)
library(htmltools)
library(tidyr)

library(modules)

swipeCards <- use("components/swipe-cards.R")

gameManager <- use("logic/gameManager.R")$gameManager$new()

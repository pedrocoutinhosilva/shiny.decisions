library(shiny)
library(shiny.grid)
library(shiny.blank)
library(htmltools)

library(modules)

swipeCards <- use("components/swipe-cards.R")

cardManager <- use("logic/deckManager.R")$deckManager$new()

gameManager <- use("logic/gameManager.R")$gameManager$new()

# browser()

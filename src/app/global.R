library(shiny)
library(shiny.grid)
library(shiny.blank)
library(htmltools)

library(modules)

mainMap <- use("components/main-map.R")
swipeCards <- use("components/swipe-cards.R")

stateMetrics <- use("components/state-metrics.R")

cardManager <- use("logic/deckManager.R")$deckManager$new()




gameManager <- use("logic/gameManager.R")$gameManager$new()

# browser()

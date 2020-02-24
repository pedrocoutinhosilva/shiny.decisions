library(shiny)
library(shiny.grid)
library(shiny.blank)
library(htmltools)

library(modules)

shiny.blank::setTemplate("nes")

mainMap <- use("components/main-map.R")
swipeCards <- use("components/swipe-cards.R")

stateMetrics <- use("components/state-metrics.R")

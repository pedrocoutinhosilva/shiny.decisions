import("R6")
import("shiny")

export("stateManager")


# Information about the current state of the game


stateManager <- R6Class("stateManager",
  public = list(
    state = NULL,

    initialize = function( karma = 50, weath = 30, opinion = 70, enviroment = 40 ) {
      self$state <- reactiveValues(
        karma = karma,
        weath = weath,
        opinion = opinion,
        enviroment = enviroment
      )
    }
  )
)

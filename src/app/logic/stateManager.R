import("R6")
import("shiny")

export("stateManager")


# Information about the current state of the game


stateManager <- R6Class("stateManager",
  public = list(
    state = NULL,

    updateState = function(newState) {

      self$state$karma <- self$state$karma + as.numeric(newState$karma)
      self$state$weath <- self$state$weath + as.numeric(newState$weath)
      self$state$opinion <- self$state$opinion + as.numeric(newState$opinion)
      self$state$enviroment <- self$state$enviroment + as.numeric(newState$enviroment)
    },

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

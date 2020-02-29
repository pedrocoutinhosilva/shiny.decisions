import("R6")
import("shiny")

export("stateManager")

# Information about the current state of the game
stateManager <- R6Class("stateManager",
  public = list(
    state = reactiveValues(
      karma = 0,
      weath = 0,
      opinion = 0,
      enviroment = 0,
      week = 0
    ),

    resetState = function() {
      isolate(self$updateState(list(
        karma = 50,
        weath = 50,
        opinion = 50,
        enviroment = 50,

        week = 1
      ), TRUE))
    },

    updateState = function(newState, force = FALSE) {
      lapply(names(newState), function(attribute) {
          self$state[[attribute]] <- ifelse (
            force,
            newState[[attribute]],
            self$state[[attribute]] + as.numeric(newState[[attribute]])
          )
      })
    }
  )
)

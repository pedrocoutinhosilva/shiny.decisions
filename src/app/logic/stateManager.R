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

    markers = list(
      trees = list(),
      fires = list()
    ),

    resetState = function() {
      isolate(self$updateState(list(
        karma = 50,
        weath = 50,
        opinion = 50,
        enviroment = 50,

        week = 1
      ), TRUE))

      self$markers = list(
        trees = list(),
        fires = list()
      )
    },

    isDeathState = function() {
      if(self$state$weath < 1 ||
         self$state$opinion < 1 ||
         self$state$enviroment < 1
      ) {
        return (TRUE)
      } else {
        return (FALSE)
      }
    },

    updateMarkers = function(newMarkers) {
      self$markers <- newMarkers
    },

    updateState = function(newState, force = FALSE) {
      lapply(names(newState), function(attribute) {
          self$state[[attribute]] <- ifelse (
            force,
            newState[[attribute]],
            self$state[[attribute]] + as.numeric(newState[[attribute]])
          )
      })

      print(reactiveValuesToList(self$state))
    }
  )
)

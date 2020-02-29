import("R6")
import("utils")
import("jsonlite")
import("glue")

export("gameManager")

stateManager <- use("logic/stateManager.R")$stateManager
deckManager <- use("logic/deckManager.R")$deckManager
mapManager <- use("logic/mapManager.R")$mapManager
metricsManager <- use("logic/metricsManager.R")$metricsManager

# data related to game state


gameManager <- R6Class("gameManager",

  private = list(
    stateManager = NULL,
    deckManager = NULL,
    mapManager = NULL,
    metricsManager = NULL
  ),

  public = list(
    newGame = function() {
      private$stateManager <- stateManager$new()
      private$metricsManager <- metricsManager$new()
      # private$deckManager <- deckManager$new()
      # private$mapManager <- mapManager$new()

      self$gameState = private$stateManager$state

      self$ui = list(
        metrics = private$metricsManager$ui
      )
    },

    ui = NULL,

    init_server = function() {
      private$metricsManager$init_server("metrics", self$gameState)
    },

    gameState = NULL,

    endGame = function() {},

    updateStatus = function() {},

    initialize = function() {
      self$newGame()
    }
  )
)

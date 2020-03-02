import("R6")
import("utils")
import("jsonlite")
import("glue")
import("shiny")
import("shiny.blank")
import("shiny.grid")

export("gameManager")

stateManager <- use("logic/stateManager.R")$stateManager
deckManager <- use("logic/deckManager.R")$deckManager
mapManager <- use("logic/mapManager.R")$mapManager
metricsManager <- use("logic/metricsManager.R")$metricsManager

# data related to game state
ui <- function() {
  tagList(
    modal(
      "entryScreen",
      content = gridPanel(
        class = "entry-screen",
        grid_template_areas = c("intro", "navigation"),
        grid_template_rows = "1fr 50px",

        div(
          class = "intro",
          "Welcome to shiny decisions! A game about making the best of bad situations"
        ),
        div(
          class = "navigation",
          button(
            "startGame",
            "Start Game",
            actions = list(
              click = "modal_entryScreen.classList.remove('open')"
            )
          )
        )
      ),
      open = TRUE,
      softClose = FALSE,
      closeButton = FALSE
    ),

    modal(
      "gameOverScreen",
      content = gridPanel(

        grid_template_areas = c("intro", "navigation"),

        div(
          class = "intro",
          "Game over"
        ),
        div(
          class = "navigation",
          button(
            "restartGame",
            "Restart Game",
            actions = list(
              click = "modal_gameOverScreen.classList.remove('open')"
            )
          )
        )
      ),
      open = FALSE,
      softClose = FALSE,
      closeButton = FALSE
    )
  )
}

gameManager <- R6Class("gameManager",

  private = list(
    stateManager = NULL,
    deckManager = NULL,
    mapManager = NULL,
    metricsManager = NULL,

    session = NULL,

    resetState = function() {
      private$stateManager <- stateManager$new()
      private$metricsManager <- metricsManager$new()
      private$mapManager <- mapManager$new()
      private$deckManager <- deckManager$new()

      self$ui = list(
        gameStages = ui,
        metrics = private$metricsManager$ui,
        map = private$mapManager$ui
      )

      self$gameState = private$stateManager$state
    },

    triggerDeathPhase = function() {
      private$deckManager$triggerDeathPhase()
    }
  ),

  public = list(
    ui = NULL,
    init_server = function(session) {
      private$session <- session

      private$metricsManager$init_server("metrics", self$gameState)
      private$mapManager$init_server("map", self$gameState)
    },

    resetGame = function() {
      self$startGame(TRUE)
    },

    startGame = function(skipTutorial = FALSE) {
      private$resetState()
      private$stateManager$resetState()
      private$deckManager$resetState(skipTutorial)

      card <- self$popCard()

      private$session$sendCustomMessage(
        "add_card",
        card
      )
    },

    popCard = function() {
      private$deckManager$popCard()
    },

    endGame = function() {},

    gameState = NULL,

    updateState = function(newState) {
      private$stateManager$updateState(newState)

      if(private$stateManager$isDeathState()) {
        private$triggerDeathPhase()
      }

      card <- self$popCard()

      if (!is.null(card) && card == "GAMEOVER") {
        private$session$sendCustomMessage(
          "game_over",
          "thanks for playing"
        )
      } else {
        private$session$sendCustomMessage(
          "add_card",
          card
        )
      }
    },

    initialize = function() {
      private$resetState()
    }
  )
)

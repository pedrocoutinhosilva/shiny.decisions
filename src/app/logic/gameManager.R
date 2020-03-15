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

dataManager <- use("logic/dataManager.R")$DataManager

game_buttons <- function() {
  div(
    class = "navigation",
    lapply(
      list(
        list(id = "startGameEasy", text = "Easy Mode"),
        list(id = "startGameMedium", text = "Medium Mode"),
        list(id = "startGameHard", text = "Hard Mode")
      ),
      function(options) {
        button(
          options$id,
          options$text,
          actions = list(
            click = "modal_entryScreen.classList.remove('open');"
          )
        )
      }
    )
  )
}

# data related to game state
ui <- function() {
  tagList(
    modal(
      "entryScreen",
      content = gridPanel(
        class = "entry-screen",
        areas = c("intro", "navigation"),
        rows = "1fr 50px",

        div(
          class = "intro",
          "Welcome to shiny decisions! A game about making the best of bad situations"
        ),
        game_buttons()
      ),
      open = TRUE,
      softClose = FALSE,
      closeButton = FALSE
    ),

    modal(
      "gameOverScreen",
      content = gridPanel(

        areas = c("intro", "navigation"),

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
    dataManager = NULL,

    gameType = "Medium",

    session = NULL,

    resetState = function() {
      private$stateManager <- stateManager$new()
      private$metricsManager <- metricsManager$new()

      if (is.null(private$dataManager)) {
        private$dataManager <- dataManager$new(
          "1LwIPKAxbKvuGyMKktcTVuYZbTda0WMQxmNMhxqaQhGg"
        )
      }

      private$mapManager <- mapManager$new(
        private$stateManager,
        private$dataManager
      )

      private$deckManager <- deckManager$new(private$dataManager)

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
      private$mapManager$init_server("map")
    },

    resetGame = function() {
      self$startGame(private$gameType, TRUE)
    },

    startGame = function(gameType, skipTutorial = TRUE) {
      private$resetState()
      private$stateManager$resetState()
      private$deckManager$resetState(gameType, skipTutorial, private$dataManager)

      private$mapManager$updateState(private$session)

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

      private$mapManager$updateState(private$session)

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

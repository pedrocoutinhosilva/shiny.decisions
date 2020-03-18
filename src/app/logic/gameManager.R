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
          p("Welcome to shiny decisions! A game about making the best of bad situations"),
          p("Try your best to lead your world in hard times and see how long you can keep it up!")
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
          "Game over",
          p(id = "game_over_message", "Game over")
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

    session = NULL,
    gameType = "Medium",

    resetState = function() {
      if (is.null(private$dataManager)) {
        private$dataManager <- dataManager$new(
          "1LwIPKAxbKvuGyMKktcTVuYZbTda0WMQxmNMhxqaQhGg"
        )
      }
      private$stateManager <- stateManager$new()
      private$metricsManager <- metricsManager$new()
      private$mapManager <- mapManager$new(private$stateManager, private$dataManager)
      private$deckManager <- deckManager$new(private$dataManager, private$stateManager)

      self$ui = list(
        gameStages = ui,
        metrics = private$metricsManager$metrics_ui,
        karma = private$metricsManager$karma_ui,
        map = private$mapManager$ui
      )
    },

    triggerDeathPhase = function() {
      private$deckManager$triggerDeathPhase()
    }
  ),

  public = list(
    ui = NULL,
    init_server = function(session) {
      private$session <- session

      private$session$sendCustomMessage("init_card_stack", TRUE)
      private$metricsManager$init_server("metrics", private$stateManager$state)
      private$mapManager$init_server("map")
    },

    resetGame = function(gameType = private$gameType) {
      self$startGame(gameType, TRUE)
    },

    startGame = function(gameType, skipTutorial = TRUE) {
      private$resetState()
      private$stateManager$resetState()
      private$deckManager$resetState(
        gameType,
        skipTutorial,
        private$dataManager,
        private$stateManager
      )
      private$mapManager$updateState(private$session)

      private$session$sendCustomMessage( "add_card", self$popCard())
    },

    popCard = function() {
      private$deckManager$popCard()
    },

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
          glue::glue("
            You survived for {private$stateManager$state$week} weeks!
            Would you like to go again?
          ")
        )
      } else {
        private$session$sendCustomMessage("add_card", card)
      }
    },

    initialize = function() {
      private$resetState()
    }
  )
)

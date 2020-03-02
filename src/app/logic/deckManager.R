import("R6")
import("utils")
import("jsonlite")
import("glue")
import("dplyr")
import("utils")

export("deckManager")

templateManager <- use("logic/dataManager.R")$DataManager

deckManager <- R6Class("deckManager",

  private = list(
    currentPhase = NULL,
    currentDeck = NULL,
    availableDecks = NULL,

    templateManager = NULL,

    loadNextDeck = function(randomizeCards = FALSE) {
      if (randomizeCards) {
        private$currentDeck <-
          jsonlite::read_json(glue::glue("cards/{private$availableDecks[1]}.json"))$cards
      } else {
        private$currentDeck <-
          sample(jsonlite::read_json(glue::glue("cards/{private$availableDecks[1]}.json"))$cards)
      }

      private$currentPhase <- private$availableDecks[1]

      if(length(private$availableDecks) != 1)
        private$availableDecks <- private$availableDecks[-1]
    },

    loadDeathDeck = function() {
      private$currentDeck <- jsonlite::read_json(glue::glue("cards/death.json"))$cards
    }
  ),

  public = list(

    getDeck = function() {
      private$currentDeck
    },

    getPhase = function() {
      private$currentPhase
    },

    triggerDeathPhase = function() {
      if(private$currentPhase != "death") {
        private$currentPhase = "death"
        private$loadDeathDeck()
      }
    },

    generateTemplateCard = function() {
      cardType <- sample(
        private$templateManager$getCardTypes(),
        size = 1,
        prob = c(0.50, 0.45, 0.05),
        replace = TRUE
      )

      cardTemplate <- sample_n(private$templateManager$getCards()[[cardType]], 1)

      intensityLevel <- sample(
        c(1:10),
        size = 1,
        prob = c(10:1),
        replace = TRUE
      )

      task <- stringr::str_replace_all(
        cardTemplate$`Template`,
        c("\\{" = "{`", "\\}" = "`}")
      )

      options <- vector("list", length(names(private$templateManager$getOptions())))

      names(options) <- names(private$templateManager$getOptions())

      for ( option in names(options)){
          options[option] <- sample_n(private$templateManager$getOptions(option), 1)
      }

      options <- modifyList(options, list(
        `Danger Level` = private$templateManager$getOptions("Danger Level")[intensityLevel,],
        `Prosperity Level` = private$templateManager$getOptions("Danger Level")[intensityLevel,]
      ))

      task <- do.call(glue::glue, modifyList(list(task), options))

      card <- list(
        background = "assets/cards/taxman.png",
        message = list (
          task = task,
          left = do.call(glue::glue, modifyList(list(options$`Ignore Message`), options)),
          right = do.call(glue::glue, modifyList(list(options$`Help Message`), options))
        ),
        delta = list(
          left = list(
            karma = 0,
            weath = 0,
            opinion = 0,
            enviroment = 0
          ),
          right = list(
            karma = 0,
            weath = 0,
            opinion = 0,
            enviroment = 0
          )
        )
      )

      return (card)
    },

    resetState = function(skipTutorial = FALSE) {
      private$currentPhase <- ""
      private$currentDeck <- list()

      if (is.null(private$templateManager)) {
        private$templateManager <- templateManager$new(
          "1LwIPKAxbKvuGyMKktcTVuYZbTda0WMQxmNMhxqaQhGg"
        )
      }

      if (skipTutorial) {
        private$availableDecks <- c("earlygame", "midgame", "lategame")
      } else {
        private$availableDecks <- c("tutorial", "earlygame", "midgame", "lategame")
      }
    },

    popCard = function() {

      # if(length(private$currentDeck) == 0) {
      #   if(private$currentPhase == "death") {
      #     return("GAMEOVER")
      #   } else {
      #     private$loadNextDeck()
      #   }
      # }
      #
      # nextCard <- private$currentDeck[1]
      #
      # private$currentDeck <- private$currentDeck[-1]

      nextCard <- self$generateTemplateCard()

      return(nextCard)
    },

    initialize = function() {
      self$resetState()
    }
  )
)

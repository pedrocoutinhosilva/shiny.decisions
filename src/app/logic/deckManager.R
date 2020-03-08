import("R6")
import("utils")
import("jsonlite")
import("glue")
import("dplyr")
import("utils")

export("deckManager")

cleanCardMessage <- function(string) {
  stringr::str_replace_all(
    string,
    c("\\{" = "{`", "\\}" = "`}")
  )
}

deckManager <- R6Class("deckManager",
  private = list(
    gameSettings = NULL,
    dataManager = NULL,

    gameFlow = NULL,
    currentDeck = NULL,

    generateTemplateCard = function() {
      deckOptions <- private$gameFlow[[private$currentDeck]]

      cardType <- sample(
        strsplit(deckOptions$`Card Pool`, ", ")[[1]],
        size = 1,
        prob = strsplit(deckOptions$`Pool Weight`, ", ")[[1]],
        replace = TRUE
      )

      if (private$gameFlow[[private$currentDeck]]$`Order Fixed`) {
        deckLimit <- nrow(private$dataManager$getCards()[[cardType]])
        deckSize <- as.numeric(private$gameFlow[[private$currentDeck]]$`Deck Size`)

        currentCardRow <- deckLimit - deckSize

        cardTemplate <- private$dataManager$getCards()[[cardType]][currentCardRow, ]
      } else {
        cardTemplate <- sample_n(private$dataManager$getCards()[[cardType]], 1)
      }

      intensityLevel <- sample(
        c(1:10),
        size = 1,
        prob = c(10:1),
        replace = TRUE
      )

      options <- vector("list", length(names(private$dataManager$getOptions())))

      names(options) <- names(private$dataManager$getOptions())

      for ( option in names(options)){
          options[option] <- sample_n(private$dataManager$getOptions(option), 1)
      }

      options <- modifyList(options, list(
        `Danger Level` = private$dataManager$getOptions("Danger Level")[intensityLevel, ],
        `Prosperity Level` = private$dataManager$getOptions("Prosperity Level")[intensityLevel, ]
      ))

      color_scale <- private$dataManager$getOptions(
        as.character(glue::glue("{cardType} Color Scale"))
      )

      background_colors <- list(
        left = as.character(color_scale[((intensityLevel * 2) - 1), ]),
        right = as.character(color_scale[(intensityLevel * 2), ])
      )

      card <- list(
        background = list(
          image = glue::glue("assets/cards/{cardTemplate$`Image`}.png"),
          color_left = background_colors$left,
          color_right = background_colors$right
        ),
        message = list (
          task = do.call(
            glue::glue,
            modifyList(list(cleanCardMessage(cardTemplate$`Template`)), options)
          ),
          left = do.call(
            glue::glue,
            modifyList(list(options$`Ignore Message`), options)
          ),
          right = do.call(
            glue::glue,
            modifyList(list(options$`Help Message`), options)
          )
        ),
        delta = list(
          left = list(
            karma = cardTemplate$`Left Karma`,
            weath = cardTemplate$`Left Wealth`,
            opinion = cardTemplate$`Left Opinion`,
            enviroment = cardTemplate$`Left Enviroment`
          ),
          right = list(
            karma = cardTemplate$`Right Karma`,
            weath = cardTemplate$`Right Wealth`,
            opinion = cardTemplate$`Right Opinion`,
            enviroment = cardTemplate$`Right Enviroment`
          )
        )
      )

      return (card)
    }
  ),

  public = list(
    getCurrentDeck = function() { private$currentDeck },

    triggerDeathPhase = function() {
      private$currentDeck = "Death"
    },

    resetState = function(gameType = "Medium", skipTutorial = FALSE, dataManager) {
      private$dataManager <- dataManager
      private$gameSettings <- private$dataManager$getGameSettings(gameType)

      private$gameFlow <- list()

      specialDecks <- strsplit(private$gameSettings$`Special Decks`, ", ")[[1]]
      gameTypeDecks <- strsplit(private$gameSettings$`Fixed Decks`, ", ")[[1]]
      gameDeckSizes <- strsplit(private$gameSettings$`Deck Sizes`, ", ")[[1]]

      lapply(gameTypeDecks, function(deckName) {
        options <- private$dataManager$getDeckOptions(deckName)

        deckIndex <- which(gameTypeDecks == deckName)[1]
        nextDeckIndex <- deckIndex + 1
        if(nextDeckIndex > length(gameTypeDecks)) nextDeckIndex <- length(gameTypeDecks)
        options$`Next Deck` <- gameTypeDecks[[nextDeckIndex]]
        options$`Deck Size` <- gameDeckSizes[[deckIndex]]
        private$gameFlow[[deckName]] <- options
      })

      lapply(specialDecks, function(deckName) {
        options <- private$dataManager$getDeckOptions(deckName)

        options$`Next Deck` <- deckName
        options$`Deck Size` <- nrow(private$dataManager$getCards()[[deckName]])

        private$gameFlow[[deckName]] <- options
      })

      if(!skipTutorial) {
        private$currentDeck <- "Tutorial"
        private$gameFlow[["Tutorial"]]$`Next Deck` <- gameTypeDecks[1]
      } else {
        private$currentDeck <- gameTypeDecks[1]
      }
    },

    popCard = function() {
      if(private$gameFlow[[private$currentDeck]]$`Deck Size` == 0) {
        if(private$currentDeck == "Death") return("GAMEOVER")

        private$currentDeck <- private$gameFlow[[private$currentDeck]]$`Next Deck`
      }

      newSize <- as.numeric(private$gameFlow[[private$currentDeck]]$`Deck Size`) - 1

      private$gameFlow[[private$currentDeck]]$`Deck Size` <- newSize

      return(private$generateTemplateCard())
    },

    initialize = function(dataManager) {
      self$resetState(dataManager = dataManager)
    }
  )
)

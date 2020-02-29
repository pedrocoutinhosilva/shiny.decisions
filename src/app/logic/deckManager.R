import("R6")
import("utils")
import("jsonlite")
import("glue")

export("deckManager")


# Manages the game state
# some phases of the game are preditermined:
# tutorial
# initial phase
# normal phase
# dead phase

# switching phases clears the deck and generates new cards for that phase


deckManager <- R6Class("deckManager",

  private = list(

    currentPhase = "",

    currentDeck = list(),
    availableDecks = c("tutorial", "earlygame", "midgame", "lategame"),

    loadNextDeck = function(randomizeCards = FALSE) {
      private$currentDeck <- jsonlite::read_json(glue::glue("cards/{private$availableDecks[1]}.json"))$cards
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
      currentPhase = "death"
      private$loadDeathDeck()
    },

    triggerGameOver = function () {
      # TODO add end state message
    },

    popCard = function() {
      if(length(private$currentDeck) == 0)
        if(private$currentPhase == "death") {
          self$triggerGameOver()
        } else {
          private$loadNextDeck()
        }
        # TODO stop death cards after the deck is over
      nextCard <- private$currentDeck[1]

      private$currentDeck <- private$currentDeck[-1]

      return(nextCard)
    },

    initialize = function() {
      private$loadNextDeck()
    }
  )
)

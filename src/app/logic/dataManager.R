import("R6")
import("googlesheets")
import("tidyr")
import("glue")

export("DataManager")

# Deals with external data
DataManager <- R6Class("DataManager",
  private = list(
    data = NULL,
    cities = NULL,
    options = NULL,
    settings = NULL,

    cards = list(),
    decks = list(),

    cardTypes = c("Tutorial", "Bad", "Good", "Special", "Death")
  ),

  public = list(
    initialize = function(sheetId) {
      # Will retry 10 times before giving up (In case of bad connection)
      for(i in 1:10){
        try({
          data <- gs_url(
            glue::glue("https://docs.google.com/spreadsheets/d/{sheetId}"),
            visibility = "public",
            lookup = FALSE
          )
          break
        })
      }

      private$settings  <- gs_read(data, ws = "Game Settings")
      private$decks     <- gs_read(data, ws = "Decks")
      private$options   <- gs_read(data, ws = "Options")
      private$cities    <- gs_read(data, ws = "Map Cities")

      lapply(private$cardTypes, function(type) {
        private$cards[[type]] <- gs_read(data, ws = type)
      })
    },

    getCities = function() {
      return(private$cities)
    },

    getSettings = function(gameType) {
      return(private$settings[which(private$settings$`Game Type` == gameType), ])
    },

    getOptions = function(attribute) {
      return(drop_na(private$options[attribute]))
    },

    getDeckOptions = function(name) {
      decks <- private$decks
      return(decks[which(decks$`Deck Name` == name), ])
    },

    getCards = function() {
      return(private$cards)
    }
  )
)

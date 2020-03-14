import("R6")
import("googlesheets")
import("tidyr")
import("glue")
import("utils")

export("DataManager")

DataManager <- R6Class("DataManager",
  private = list(
    data = NULL,

    cities = NULL,

    options = NULL,
    gameSettings = NULL,

    cards = list(),
    decks = list(),

    cardTypes = c("Tutorial", "Bad", "Good", "Special", "Death")
  ),

  public = list(
    initialize = function(sheetId) {
      for(i in 1:10){
        try({
          # data <- gs_key(sheetId, visibility = "public", lookup = FALSE)
          data <- gs_url(
            glue::glue("https://docs.google.com/spreadsheets/d/{sheetId}"),
            visibility = "public",
            lookup = FALSE
          )
          break
        })
      }

      private$gameSettings <- gs_read(data, ws = "Game Settings")
      private$decks <- gs_read(data, ws = "Decks")
      private$options <- gs_read(data, ws = "Options")

      private$cities <- data.frame(read.csv("./data/worldcities.csv"))

      lapply(private$cardTypes, function(type) {
        private$cards[[type]] <- gs_read(data, ws = type)
      })
    },

    getCities = function() {
      return(private$cities)
    },

    getData = function() {
      return(private$data)
    },

    getGameSettings = function(gameType) {
      return(private$gameSettings[which(private$gameSettings$`Game Type` == gameType), ])
    },

    getCardTypes = function() {
      return(private$cardTypes)
    },

    getOptions = function(attribute) {
      return(drop_na(private$options[attribute]))
    },

    getDecks = function() {
      return(private$decks)
    },

    getDeckOptions = function(name) {
      decks <- self$getDecks()
      return(decks[which(decks$`Deck Name` == name), ])
    },

    getCards = function() {
      return(private$cards)
    }
  )
)

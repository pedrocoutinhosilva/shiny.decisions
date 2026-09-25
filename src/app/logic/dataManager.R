import("R6")
import("tidyr")
import("glue")
import("utils")

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
    initialize = function(sheetId, force_update = FALSE) {
      if (force_update) {
        print("Updating from online data")

        # The sheet is public, so its xlsx export needs no authentication.
        # Download to a temp file first so a failure keeps the cached copy.
        tryCatch({
          download <- tempfile(fileext = ".xlsx")
          utils::download.file(
            glue::glue("https://docs.google.com/spreadsheets/d/{sheetId}/export?format=xlsx"),
            download,
            mode = "wb",
            quiet = TRUE
          )
          file.copy(download, "data/options.xlsx", overwrite = TRUE)
        }, error = function(e) {
          message("Using cached options.xlsx: ", conditionMessage(e))
        })
      }

      private$settings  <- readxl::read_xlsx("data/options.xlsx", "Game Settings")
      private$decks     <- readxl::read_xlsx("data/options.xlsx", "Decks")
      private$options   <- readxl::read_xlsx("data/options.xlsx", "Options")
      private$cities    <- readxl::read_xlsx("data/options.xlsx", "Map Cities")

      lapply(private$cardTypes, function(type) {
        private$cards[[type]] <- readxl::read_xlsx("data/options.xlsx", sheet = type)
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

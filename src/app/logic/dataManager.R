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

      online_metadata <- googlesheets::gs_url(
          glue::glue("https://docs.google.com/spreadsheets/d/{sheetId}"),
          visibility = "public",
          lookup = FALSE
      )

      if (file.exists("data/sheet_info.json") && file.exists("data/options.xlsx")) {
        cached_version <- jsonlite::read_json("data/sheet_info.json")$updated[[1]]
        online_version <- online_metadata$updated
        is_up_to_date <- as.POSIXct(online_version) %in% c(as.POSIXct(cached_version))
      } else (
        is_up_to_date <- FALSE
      )

      if (!is_up_to_date) {
        print("Updating from online data")
        gs_download(online_metadata, to = "data/options.xlsx", overwrite = TRUE)
        jsonlite::write_json(online_metadata, "data/sheet_info.json")
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

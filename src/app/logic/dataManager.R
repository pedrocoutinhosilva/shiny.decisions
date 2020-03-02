import("R6")
import("googlesheets")
import("tidyr")
import("glue")

export("DataManager")

DataManager <- R6Class("DataManager",
  private = list(
    data = NULL,

    options = NULL,
    cards = list(),

    cardTypes = c("Bad", "Good", "Special")
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

      private$options <- gs_read(data, ws = "Options")

      lapply(private$cardTypes, function(type) {
        private$cards[[type]] <- gs_read(data, ws = type)
      })
    },

    getData = function() {
      return(private$data)
    },

    getCardTypes = function() {
      return(private$cardTypes)
    },

    getOptions = function(attribute) {
      return(drop_na(private$options[attribute]))
    },

    getCards = function() {
      return(private$cards)
    }
  )
)

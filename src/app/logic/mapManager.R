import("R6")
import("utils")
import("jsonlite")
import("glue")
import("shiny.blank")
import("leaflet")
import("shiny")

export("mapManager")


ui <- function(id) {
  ns <- NS(id)

  leafletOutput(ns("mainMap"), height = "100%")
}

server <- function(input, output, session, state) {
  ns <- session$ns

  output$mainMap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Stamen.Watercolor",
        options = providerTileOptions(noWrap = TRUE)
      ) %>%
      setView(0, 0, 2)
  })
}

mapManager <- R6Class("mapManager",

  private = list(
    server = server
  ),

  public = list(
    ui = ui,
    init_server = function(id, state) {
      callModule(private$server, id, state)
    }
  )
)

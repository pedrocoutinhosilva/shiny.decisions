import("shiny")
import("modules")
import("shiny.blank")
import("leaflet")

export('ui')
export('init_server')

ui <- function(id) {
  ns <- NS(id)

  leafletOutput(ns("mainMap"), height = "100%")
}

init_server <- function(id) {
  callModule(server, id)
}

server <- function(input, output, session) {
  ns <- session$ns
  output$mainMap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Stamen.Watercolor",
        options = providerTileOptions(noWrap = TRUE)
      ) %>%
      setView(0 , 0, 2)
  })
}

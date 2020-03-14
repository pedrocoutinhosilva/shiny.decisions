import("R6")
import("utils")
import("jsonlite")
import("glue")
import("shiny.blank")
import("leaflet")
import("shiny")
import("dplyr")

export("mapManager")

# continents <- readLines("data/continents.json") %>% paste(collapse = "\n")

ui <- function(id) {
  ns <- NS(id)

  script <- glue::glue("
    let updateMapStyle = function(options) {
      sepia = (100 - options.enviroment) / 100
      $('#map-mainMap .leaflet-tile').css('filter', `sepia(${sepia})`)
    }
    Shiny.addCustomMessageHandler('updateMapStyle', updateMapStyle)
  ", .open = "<<", .close = ">>")

  tagList(
    tags$script(HTML(script)),
    leafletOutput(ns("mainMap"), height = "100%")
  )
}

updateMarkers <- function(markers, required, icon, class_name, map, dataManager) {
  if(is.null(markers)) markers = list()

  current <- ifelse(
    is.data.frame(markers),
    nrow(markers),
    0
  )

  if(length(markers) == 0) {
    markers <- sample_n(dataManager$getCities(), required)[c("lat", "lng")]
  }
  if(required < current) {
    markers <- sample_n(markers, required)[c("lat", "lng")]
  }
  if(required > current) {
    markers <- rbind(
      markers,
      sample_n(dataManager$getCities(), required - current)[c("lat", "lng")]
    )
  }

  if (length(markers) > 0 ) {
    map <- map %>%
    addMarkers(data = markers, lng = ~lng, lat = ~lat,
    icon = list(
      iconUrl = icon,
      iconSize = c(30, 30),
      className = class_name
     ))
  }

  return(markers)
}

server <- function(input, output, session, stateManager, dataManager) {
  ns <- session$ns

  output$mainMap <- renderLeaflet({
    leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      addProviderTiles("Stamen.Watercolor",
        options = providerTileOptions(noWrap = TRUE)
      ) %>%
      # addGeoJSON(continents, weight = 1, color = "#444444", fill = FALSE) %>%
      setView(0, 0, 2)
  })

  observe({
    map <- leafletProxy("map-mainMap") %>%
      clearMarkers()
    current <- reactiveValuesToList(stateManager$state)
    markers <- stateManager$markers

    categories <- list(
      cold = list(
        requirement = floor(current$enviroment/30),
        icon = "assets/map/cold.png"
      ),
      fires = list(
        requirement = floor(current$enviroment/20),
        icon = "assets/map/fire.png"
      ),
      money = list(
        requirement = floor(current$weath/20),
        icon = "assets/map/money.png"
      ),
      mad = list(
        requirement = floor(current$opinion/20),
        icon = "assets/map/mad.png"
      ),
      angry = list(
        requirement = floor(current$opinion/40),
        icon = "assets/map/mad.png"
      ),
      smile = list(
        requirement = floor(current$opinion/5),
        icon = "assets/map/smile.png"
      ),
      trees = list(
        requirement = current$enviroment,
        icon = "assets/map/tree.png"
      )
    )

    for(category in names(categories)) {
      stateManager$markers[[category]] <- updateMarkers(
        markers = markers[[category]],
        required = categories[[category]]$requirement,
        icon = categories[[category]]$icon,
        class_name = paste0("marker-", category),
        map = map,
        dataManager = dataManager
      )
    }
  })
}

mapManager <- R6Class("mapManager",

  private = list(
    server = server,
    stateManager = NULL,
    dataManager = NULL
  ),

  public = list(
    ui = ui,
    init_server = function(id) {
      callModule(private$server, id, private$stateManager, private$dataManager)
    },

    updateState = function(session) {
      state <- private$stateManager$state

      session$sendCustomMessage(
        "updateMapStyle",
        reactiveValuesToList(state)
      )
    },

    initialize = function(stateManager, dataManager) {
      private$stateManager <- stateManager
      private$dataManager <- dataManager
    }
  )
)

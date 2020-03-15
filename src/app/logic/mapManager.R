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

updateMarkers <- function(markers, required, name, map, dataManager) {
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
      iconUrl = paste0("assets/map/", name, ".png"),
      iconSize = c(30, 30),
      className = paste0("marker-", name)
     ))
  }

  return(markers)
}

server <- function(input, output, session, stateManager, dataManager) {
  ns <- session$ns

  output$mainMap <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        preferCanvas = TRUE,
        zoomControl = FALSE,
        dragging = FALSE,
        minZoom = 2,
        maxZoom = 2)
      ) %>%
      # setMaxBounds(
      #   lng1 = 0,
      #   lat1 = 0,
      #   lng2 = 0,
      #   lat2 = 0
      # ) %>%
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

    base <- list(
      enviroment = floor(current$enviroment/10),
      weath = floor(current$weath/10),
      opinion = floor(current$opinion/10)
    )

    # Marker categories for stats indicators
    categories <- list()
    # Enviroment indicators
    # Trees start at zero and grow with the current enviroment
    categories$tree <- base$enviroment * 5
    categories$tree_large <- base$enviroment
    categories$tree_small <- base$enviroment * 2
    # Fires appear at 40 enviroment an increase numbers as it gets lower
    categories$fire <- ifelse(current$enviroment <= 40, (5 - base$enviroment), 0)
    # Cold appear at 40 enviroment an increase numbers as it gets lower
    categories$cold <- ifelse(current$enviroment <= 40, (5 - base$enviroment), 0)

    # Wealth Indicators
    # Broken houses start apearing at 50 wealth and increase numbers as it gets lower
    categories$house_broken <- ifelse(current$weath <= 50, (6 - base$weath), 0)
    # Mormal houses grow up to 50 wealth and start decreasing after that
    if (current$weath >= 50) categories$house <- (11 - base$weath)
    else categories$house <- base$weath
    # Office buildings apearing at 50 wealth and increase numbers as it gets higher
    categories$office <- ifelse( current$weath >= 50, (base$weath - 4), 0)

    # Opinion Indicators
    # Mad people start apearing at 50 opinion and increase numbers as it gets lower
    categories$mad <- ifelse(current$opinion <= 50, (6 - base$opinion), 0)
    # Smily people grow up to 50 opinion and start decreasing after that
    if (current$opinion >= 50) categories$smile <- (11 - base$opinion)
    else categories$smile <- base$weath
    # Super happy people apearing at 50 opinion and increase numbers as it gets higher
    categories$stareyes <- ifelse(current$opinion >= 50, (base$opinion - 4), 0)

    for(category in names(categories)) {
      stateManager$markers[[category]] <- updateMarkers(
        markers = markers[[category]],
        required = categories[[category]],
        name = category,
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

import("R6")
import("shiny")
import("glue")
import("shiny.grid")
import("shiny.blank")

export("metricsManager")

metricCard <- function(id, label, class, icon) {
  div(
    class = glue::glue("{class} metric-wrapper"),

    div(
      class = "metric-icon",
      style = glue::glue("background-image: url('{icon}')")
    ),
    tags$label(label),
    uiOutput(id, class = id)
  )
}

ui <- function(id) {
  ns <- NS(id)

  gridPanel(
    areas = c("metric-karma metric-wealth metric-opinion metric-enviroment"),
    class = "metrics",

    metricCard(
      ns("stateKarma"),
      "Karma",
      "metric-karma",
      "assets/ui/icons/halo.png"
      ),
    metricCard(
      ns("stateWealth"),
      "Wealth",
      "metric-wealth",
      "assets/ui/icons/gold.png"
      ),
    metricCard(
      ns("stateOpinion"),
      "Opinion",
      "metric-opinion",
      "assets/ui/icons/friend.png"
      ),
    metricCard(
      ns("stateEnviroment"),
      "Enviroment",
      "metric-enviroment",
      "assets/ui/icons/salad.png"
    )
  )
}

server <- function(input, output, session, state) {
  ns <- session$ns

  output$stateKarma <- renderUI(
    div(
      class = "karma-wrapper",
      progress(
        ns("stateKarmaNegative"),
        value = ifelse(state$karma < 50, (50 - state$karma) * 2, 0),
        type = "is-error negative"
      ),
      progress(
        ns("stateKarmaPositive"),
        value = ifelse(state$karma > 49, (state$karma - 50) * 2, 0),
        type = "is-primary positive"
      )
    )
  )
  output$stateWealth <- renderUI(
    progress(ns("stateWealth"), value = state$wealth, type = "is-warning")
  )
  output$stateOpinion <- renderUI(
    progress(ns("stateOpinion"), value = state$opinion, type = "is-opinion")
  )
  output$stateEnviroment <- renderUI(
    progress(ns("stateEnviroment"), value = state$enviroment, type = "is-success")
  )
}

# Manages the UI displaying the state metrics.
metricsManager <- R6Class("metricsManager",
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

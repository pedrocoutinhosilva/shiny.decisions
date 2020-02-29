import("shiny")
import("modules")
import("shiny.grid")
import("glue")

export('ui')


metricCard <- function(id, label, class) {
  div(
    class = glue::glue("{class} metric-wrapper"),

    tags$label(label),
    uiOutput(id, class = id)
  )
}

ui <- function(id) {
  ns <- NS(id)

  gridPanel(
    grid_template_rows = "1fr",
    grid_template_columns = "1fr 1fr 1fr 1fr",
    grid_template_areas = c(
      "metric-karma metric-wealth metric-opinion metric-enviroment"
    ),

    class = "metrics",

    metricCard(ns("stateKarma"), "Evil", "metric-karma"),
    metricCard(ns("stateWealth"), "Wealth", "metric-wealth"),
    metricCard(ns("stateOpinion"), "Opinion", "metric-opinion"),
    metricCard(ns("stateEnviroment"), "Enviroment", "metric-enviroment")
  )
}

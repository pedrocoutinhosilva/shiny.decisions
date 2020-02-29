import("shiny")
import("modules")
import("shiny.grid")
import("glue")

export('ui')
export('init_server')


metricCard <- function(id, label, class) {
  div(
    class = glue::glue("{class} metric-wrapper"),

    div(class = "metric-icon"),
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
      "metric-karma metric-opinion metric-enviroment metric-wealth"
    ),

    class = "metrics",

    metricCard("stateKarma", "Evilness", "metric-karma"),
    metricCard("stateOpinion", "Population", "metric-opinion"),
    metricCard("stateEnviroment", "Enviroment", "metric-enviroment"),
    metricCard("stateWealth", "Wealth", "metric-wealth")
  )
}

init_server <- function(id) {
  callModule(server, id)
}

server <- function(input, output, session) {
  ns <- session$ns
}

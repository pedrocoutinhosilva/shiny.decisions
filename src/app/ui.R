blankPage(
  title = "Shiny Decisions",
  theme = "nes",


  tags$head(
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/hammer.js/2.0.8/hammer.min.js"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),

  tags$style("html, body { height: 100%; width: 100%; overflow: hidden; }"),

  gridPanel(
    grid_template_rows = "100px 1fr 1fr",
    grid_template_columns = "1fr 1fr 1fr",
    grid_template_areas = c(
      "header header header",
      "main main actions",
      "main main actions"
    ),

    gridPanel(
      position = "header",
      style = "color: #fff; background-color: #212529;",

      grid_template_rows = "1fr",
      grid_template_columns = "5fr",
      grid_template_areas = c(
        "metrics"
      ),

      stateMetrics$ui("metrics")
    ),

    gridPanel(
      position = "actions",
      style = "overflow: visible; z-index: 1; ",
      swipeCards$swipeCardStack("stack")
    ),

    gridPanel(
      position = "main",
      style = "background: yellow",

      mainMap$ui("mainMap")
    )
  )
)

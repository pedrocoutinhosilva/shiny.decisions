blankPage(
  title = "Shiny Decisions",
  theme = "nes",

  tags$head(
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/hammer.js/2.0.8/hammer.min.js"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),

  gridPanel(
    grid_template_rows = "100px 1fr",
    grid_template_areas = c(
      "app-metrics app-metrics app-metrics",
      "app-map app-map app-cards"
    ),

    gridPanel(
      position = "app-metrics",
      gameManager$ui$metrics("metrics")
    ),

    gridPanel(
      position = "app-cards",
      swipeCards$swipeCardStack("stack")
    ),

    gridPanel(
      position = "app-map",
      mainMap$ui("mainMap")
    )
  )
)

blankPage(
  title = "Shiny Decisions",
  theme = "nes",

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles/styles.css")
  ),

  gameManager$ui$gameStages(),

  gridPanel(
    id = "page-wrapper",
    rows = "100px 1fr",
    areas = c(
      "app-metrics app-metrics app-metrics",
      "app-map app-map app-cards"
    ),

    gridPanel(
      class = "app-metrics",
      gameManager$ui$metrics("metrics")
    ),

    gridPanel(
      class = "app-cards",
      swipeCards$swipeCardStack()
    ),

    gridPanel(
      class = "app-map",
      gameManager$ui$map("map")
    )
  )
)

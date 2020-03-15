import("shiny")
import("modules")
import("shiny.blank")

export("swipeCardStack")

swipeCardStack <- function(inputId = "card_stack") {
  html <- tagList(
    div(
      id = glue::glue("{inputId}_wrapper"),

      div(
        id = glue::glue("{inputId}_message"),
        p("")
      ),
      div(id = inputId)
    ),    
    tags$script(src = "scripts/hammer.min.js"),
    tags$script(src = "scripts/card_stack.js")
  )

  component(html = html)
}

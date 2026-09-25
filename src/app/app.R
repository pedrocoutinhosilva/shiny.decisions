# Single-file entry point for hosts that need one primary file, such as
# Posit Connect Cloud. Shiny does not source global.R for app.R apps.
source("global.R")
ui <- source("ui.R")$value
server <- source("server.R")$value

shinyApp(ui, server)

function(input, output, session) {
  mainMap$init_server("mainMap")

  state <- reactiveValues(
    karma = 50,
    weath = 30,
    opinion = 70,
    enviroment = 40
  )

  output$stateKarma <- renderUI(
    progress("stateKarma", value = state$karma, type = "is-error")
  )
  output$stateWealth <- renderUI(
    progress("stateWealth", value = state$weath, type = "is-warning")
  )
  output$stateOpinion <- renderUI(
    progress("stateOpinion", value = state$opinion, type = "is-primary")
  )
  output$stateEnviroment <- renderUI(
    progress("stateEnviroment", value = state$enviroment, type = "is-success")
  )

  session$sendCustomMessage(
    "add_card",
    list(
      message = list(
        task = "example card",
        left = "ok",
        right = "nope"
      ),
      delta = list(
        left = list (
          karma = -10,
          weath = 0,
          opinion = -10,
          enviroment = 15
        ),
        right = list(
          karma = -10,
          weath = 20,
          opinion = 10,
          enviroment = -25
        )
      )
    )
  )

  session$sendCustomMessage(
    "add_card",
    list(
      message = list(
        task = "another example card",
        left = "ok",
        right = "nope"
      ),
      delta = list(
        left = list (
          karma = -20,
          weath = 40,
          opinion = -20,
          enviroment = 25
        ),
        right = list(
          karma = 20,
          weath = -40,
          opinion = 20,
          enviroment = -25
        )
      )
    )
  )



  observeEvent(input$update_state, {

    print(input$update_state)

    state$karma <- state$karma + as.numeric(input$update_state$karma)
    state$weath <- state$weath + as.numeric(input$update_state$weath)
    state$opinion <- state$opinion + as.numeric(input$update_state$opinion)
    state$enviroment <- state$enviroment + as.numeric(input$update_state$enviroment)

    session$sendCustomMessage(
      "add_card",
      list(
        message = list(
          task = "event generated example card with a longer message",
          left = "ok",
          right = "nope"
        ),
        delta = list(
          left = list (
            karma = -20,
            weath = 40,
            opinion = -20,
            enviroment = 25
          ),
          right = list(
            karma = 20,
            weath = -40,
            opinion = 20,
            enviroment = -25
          )
        )
      )
    )
  })
}

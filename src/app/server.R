function(input, output, session) {
  mainMap$init_server("mainMap")

  state <- gameManager$gameState

  gameManager$init_server()

  session$sendCustomMessage(
    "add_card",
    cardManager$popCard()
  )

  observeEvent(input$update_state, {

    # state$updateState(input)

    state$karma <- state$karma + as.numeric(input$update_state$karma)
    state$weath <- state$weath + as.numeric(input$update_state$weath)
    state$opinion <- state$opinion + as.numeric(input$update_state$opinion)
    state$enviroment <- state$enviroment + as.numeric(input$update_state$enviroment)

    # gameManager$updateState()

    if(state$weath < 1 ||
       state$opinion < 1 ||
       state$enviroment < 1
    ) {
      print("death")
      cardManager$triggerDeathPhase()
    }

    session$sendCustomMessage(
      "add_card",
      cardManager$popCard()
    )
  })
}

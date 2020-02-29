function(input, output, session) {
  state <- gameManager$gameState

  gameManager$init_server()

  session$sendCustomMessage(
    "add_card",
    cardManager$popCard()
  )

  observeEvent(input$update_state, {

    gameManager$updateState(input$update_state)

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

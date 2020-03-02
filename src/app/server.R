function(input, output, session) {

  gameManager$init_server(session)

  observeEvent(input$update_state, {
    gameManager$updateState(input$update_state)
  })

  observeEvent(input$startGame, {
    gameManager$startGame()
  })
  observeEvent(input$restartGame, {
    gameManager$resetGame()
  })
}

function(input, output, session) {

  gameManager$init_server(session)

  observeEvent(input$update_state, {
    gameManager$updateState(input$update_state)
  })

  observeEvent(input$startGame, {
    gameManager$startGame()
  })
  observeEvent(input$startGameEasy, {
    gameManager$startGame("Easy")
  })
  observeEvent(input$startGameMedium, {
    gameManager$startGame("Medium")
  })
  observeEvent(input$startGameHard, {
    gameManager$startGame("Hard")
  })
  observeEvent(input$restartGame, {
    gameManager$resetGame()
  })
}

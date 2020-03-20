function(input, output, session) {

  session$userData$gameManager <- use("logic/gameManager.R")$gameManager$new()
  session$userData$gameManager$init_server(session)

  observeEvent(input$update_state, {
    session$userData$gameManager$updateState(input$update_state)
  })

  observeEvent(input$startGame, {
    session$userData$gameManager$startGame()
  })
  observeEvent(input$startGameEasy, {
    session$userData$gameManager$startGame("Easy")
  })
  observeEvent(input$startGameMedium, {
    session$userData$gameManager$startGame("Medium")
  })
  observeEvent(input$startGameHard, {
    session$userData$gameManager$startGame("Hard")
  })
  observeEvent(input$restartGame, {
    session$userData$gameManager$resetGame()
  })
}

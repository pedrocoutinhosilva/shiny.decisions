import("shiny")
import("modules")
import("shiny.blank")

export("swipeCardStack")

swipeCardStack <- function(inputId = "card_stack") {

  script <- glue::glue("
  class Carousel {

    constructor(element) {
      this.board = element
      this.handle()
    }

    handle() {
      this.cards = this.board.querySelectorAll('.card')
      this.topCard = this.cards[this.cards.length-1]
      this.nextCard = this.cards[this.cards.length-2]
      if (this.cards.length > 0) {

        this.topCard.style.transform =
          'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(1)'

        if (this.hammer) this.hammer.destroy()

        this.hammer = new Hammer(this.topCard)
        this.hammer.add(new Hammer.Tap())
        this.hammer.add(new Hammer.Pan({
          position: Hammer.position_ALL, threshold: 0
        }))

        this.hammer.on('tap', (e) => { this.onTap(e) })
        this.hammer.on('pan', (e) => { this.onPan(e) })

        document.querySelector('#<<inputId>>_wrapper p').textContent = this.topCard.getAttribute('message-task')

      }

    }

    onTap(e) {

      let propX = (e.center.x - e.target.getBoundingClientRect().left) / e.target.clientWidth

      let rotateY = 15 * (propX < 0.05 ? -1 : 1)

      this.topCard.style.transition = 'transform 100ms ease-out'

      this.topCard.style.transform =
        'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(' + rotateY + 'deg) scale(1)'

      setTimeout(() => {
        this.topCard.style.transform =
          'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(1)'
      }, 100)

    }

    onPan(e) {

      if (!this.isPanning) {

        this.isPanning = true

        this.topCard.style.transition = null
        if (this.nextCard) this.nextCard.style.transition = null

        let style = window.getComputedStyle(this.topCard)
        let mx = style.transform.match(/^matrix\\((.+)\\)$/)
        this.startPosX = mx ? parseFloat(mx[1].split(', ')[4]) : 0
        this.startPosY = mx ? parseFloat(mx[1].split(', ')[5]) : 0

        let bounds = this.topCard.getBoundingClientRect()

        this.isDraggingFrom =
          (e.center.y - bounds.top) > this.topCard.clientHeight / 2 ? -1 : 1

      }

      let posX = e.deltaX + this.startPosX
      let posY = e.deltaY + this.startPosY

      let propX = e.deltaX / this.board.clientWidth
      let propY = e.deltaY / this.board.clientHeight

      let dirX = e.deltaX < 0 ? -1 : 1

      let delta_threshold = 10
      let delta_direction = ''

      if(dirX > 0) {
        this.topCard.classList.add('dragging-right')
        this.topCard.classList.remove('dragging-left')
        delta_direction = 'right'
      } else {
        this.topCard.classList.add('dragging-left')
        this.topCard.classList.remove('dragging-right')
        delta_direction = 'left'
      }

      Object.values(document.querySelectorAll(`.metric-wrapper`)).map(x => {
        x.classList.remove('will-change', 'will-change-large')
      })

      Object.entries({
        karma: Number(carousel.topCard.getAttribute(`delta-${delta_direction}-karma`)),
        wealth: Number(carousel.topCard.getAttribute(`delta-${delta_direction}-weath`)),
        opinion: Number(carousel.topCard.getAttribute(`delta-${delta_direction}-opinion`)),
        enviroment: Number(carousel.topCard.getAttribute(`delta-${delta_direction}-enviroment`))
      }).map(attribute => {
        if(attribute[1] !== 0) {
          document.querySelector(`.metric-${attribute[0]}`)
            .classList.add(
              (attribute[1]  > delta_threshold)
                ? 'will-change-large'
                : 'will-change'
              )
        }
      })

      let deg = this.isDraggingFrom * dirX * Math.abs(propX) * 45

      let scale = (95 + (5 * Math.abs(propX))) / 100

      this.topCard.style.transform =
        'translateX(' + posX + 'px) translateY(' + posY + 'px) rotate(' + deg + 'deg) rotateY(0deg) scale(1)'

      if (this.nextCard) this.nextCard.style.transform =
        'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(' + scale + ')'

      if (e.isFinal) {
        this.isPanning = false
        let successful = false

        let direction = ''

        this.topCard.classList.remove('dragging-left')
        this.topCard.classList.remove('dragging-right')

        Object.values(document.querySelectorAll(`.metric-wrapper`)).map(x => {
          x.classList.remove('will-change', 'will-change-large')
        })

        this.topCard.style.transition = 'transform 200ms ease-out'
        if (this.nextCard) this.nextCard.style.transition = 'transform 100ms linear'

        if (propX > 0.15 && e.direction == Hammer.DIRECTION_RIGHT) {

          direction = 'RIGHT'
          successful = true
          posX = this.board.clientWidth

        } else if (propX < -0.15 && e.direction == Hammer.DIRECTION_LEFT) {

          direction = 'LEFT'
          successful = true
          posX = - (this.board.clientWidth + this.topCard.clientWidth)

        }

        if (successful) {

          this.topCard.style.transform =
            'translateX(' + posX + 'px) translateY(' + posY + 'px) rotate(' + deg + 'deg)'

          let delta = {}

          if(direction == 'LEFT') {
            delta = {
              karma: this.topCard.getAttribute('delta-left-karma'),
              wealth: this.topCard.getAttribute('delta-left-weath'),
              opinion: this.topCard.getAttribute('delta-left-opinion'),
              enviroment: this.topCard.getAttribute('delta-left-enviroment')
            }
          }

          if(direction == 'RIGHT') {
            delta = {
              karma: this.topCard.getAttribute('delta-right-karma'),
              wealth: this.topCard.getAttribute('delta-right-weath'),
              opinion: this.topCard.getAttribute('delta-right-opinion'),
              enviroment: this.topCard.getAttribute('delta-right-enviroment')
            }
          }

          console.log(delta)

          setTimeout(() => {
            Shiny.setInputValue('update_state', {
              karma: delta.karma,
              weath: delta.wealth,
              opinion: delta.opinion,
              enviroment: delta.enviroment
            }, {priority : 'event'})

            this.board.removeChild(this.topCard)
            this.handle()

            console.log('card removed', direction, e.direction)

          }, 200)

        } else {

          this.topCard.style.transform =
            'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(1)'
          if (this.nextCard) this.nextCard.style.transform =
            'translateX(-50%) translateY(-50%) rotate(0deg) rotateY(0deg) scale(0.95)'

        }

      }

    }

    push({ background, message, delta }) {
      let card = document.createElement('div')

      let card_color = document.createElement('div')
      let card_image = document.createElement('div')

      let message_left = document.createElement('p')
      let message_right = document.createElement('p')

      message_left.classList.add('message-left')
      message_left.textContent = message.left

      message_right.classList.add('message-right')
      message_right.textContent = message.right

      card.append(message_left)
      card.append(message_right)

      card.append(card_image)
      card.append(card_color)

      card.classList.add('card')

      console.log(message, delta)

      Object.entries({
        'message-task': message.task,
        'message-left': message.left,
        'message-right': message.right,

        'delta-left-karma': delta.left.karma,
        'delta-left-weath': delta.left.weath,
        'delta-left-opinion': delta.left.opinion,
        'delta-left-enviroment': delta.left.enviroment,

        'delta-right-karma': delta.right.karma,
        'delta-right-weath': delta.right.weath,
        'delta-right-opinion': delta.right.opinion,
        'delta-right-enviroment': delta.right.enviroment
      }).map(attribute => {
        card.setAttribute(attribute[0], attribute[1])
      })

      card_image.classList.add('card-background', 'card-image')
      card_color.classList.add('card-background', 'card-color')

      card_color.style.background = `linear-gradient(
        135deg,
        ${background.color_left} 0%,
        ${background.color_left} 50%,
        ${background.color_right} 51%,
        ${background.color_right} 100%)`

      card_image.style.background =
        `url(${background.image})`

      if (this.board.firstChild) {
        this.board.insertBefore(card, this.board.firstChild)
      } else {
        this.board.append(card)
      }

    }
  }

  let carousel = new Carousel(document.querySelector('#<<inputId>>'))

  let addCard = function(options) {

    console.log(options)

    carousel.push(options)
    carousel.handle()
  }
  Shiny.addCustomMessageHandler('add_card', addCard);

  let gameOver = function(options) {
    modal_gameOverScreen.classList.add('open')
  }
  Shiny.addCustomMessageHandler('game_over', gameOver);

  ", .open = "<<", .close = ">>")

  html <- div(
    id = glue::glue("{inputId}_wrapper"),

    div(
      id = glue::glue("{inputId}_message"),
      p("")
    ),
    div(id = inputId)
  )

  component(html = html, script = HTML(script))
}

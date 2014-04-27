#--------Game-----------------------

WIDTH = window.innerWidth * 0.3
HEIGHT = (if WIDTH < window.innerHeight - 70 then WIDTH - 10 else window.innerHeight - 70)
FPS = 60

class Game
  constructor: ->
    @createCanvas()
    @prepareCanvas()
    @createSprites()
    @initializeKeyboard()
    @start()

  createCanvas: ->
    @canvas = document.createElement('canvas')
    $('#body-container').append(@canvas)
  
  prepareCanvas: ->
    @canvas.width = WIDTH
    @canvas.height = HEIGHT
    $(@canvas).css({'position':'absolute','left':'50%','margin-left':"-#{@canvas.width / 2}px",'top':'50%','margin-top':"-#{@canvas.height / 2}px", 'border':'1px solid black'})
    @context = @canvas.getContext('2d')

  start: ->
    @timer = setInterval =>
      @run()
    , 1000 / FPS

  run: ->
    @sprites.forEach (sprite) => sprite.update(@)
    @sprites.forEach (sprite) => sprite.draw(@context)

  restart: ->
    @stop()
    @createSprites()
    @start()

  stop: ->
    clearInterval(@timer)
    @timer = null

  running: ->
    @timer?

  createSprites: ->
    @sprites = []
    @score = 0

    @sprites.push new Background
    @sprites.push @player = new Player (@)
    @sprites.push @enemy = new Enemy

  initializeKeyboard: ->
    $("body").on
      'keydown': (e) ->
        if game.running
          e.preventDefault()
          switch e.keyCode
            when 37 then game.player.left = true
            when 38 then game.player.up = true
            when 39 then game.player.right = true
            when 40 then game.player.down = true

      'keyup': (e) ->
        if game.running
          e.preventDefault()
          switch e.keyCode
            when 37 then game.player.left = false
            when 38 then game.player.up = false
            when 39 then game.player.right = false
            when 40 then game.player.down = false

class Sprite
  x: 0
  y: 0

  xVelocity: 0
  yVelocity: 0

  imagePath: null

  constructor: ->
    @image = new Image
    @image.src = @imagePath
    @image.onload = => @ready = true
    { @width, @height } = @image

  update: (game) ->
    @x += @xVelocity
    @y += @yVelocity

  draw: (context) ->
    context.drawImage(@image, @x, @y, @width, @height)

  remove: ->
    i = game.sprites.indexOf(this)
    game.sprites.slice(i, 1)

  isColliding: (other) ->
    margin = @width / 3

    !(((@y + @height - margin) < (other.y)) ||
      (@y + margin > (other.y + other.height)) ||
      (@x + @width - margin) < (other.x) ||
      (@x + margin) > (other.x + other.width))

class Enemy extends Sprite
  imagePath: '/images/enemy.png'

  constructor: ->
    super
    @width = 25
    @height = 25

  update: (game) ->
    #if @isColliding(game.player)
    #die()
    
    super

class Player extends Sprite
  imagePath: '/images/player.png'

  constructor: (game) ->
    super
    @width = 25
    @height = 25

    #Initial Position
    @x = game.canvas.width - @width
    @y = game.canvas.height - @height

  update: ->
    unless @up || @down
      @yVelocity = 0
    else
      if @up
        @yVelocity = -5

      if @down
        @yVelocity = 5
    
    unless @left || @right
      @xVelocity = 0
    else
      if @left
        @xVelocity = -5

      if @right
        @xVelocity = 5

    super

class Background extends Sprite
  imagePath: '/images/stars.jpg'

window.Game = Game

#--------On Click Listeners ---------
$(document).ready( ->
  $('#startModal').modal()

  $(document).on('click', '.play', (e) ->
    $('#startModal').modal('hide')
    $('.play').hide()
    window.game = new Game()
    e.preventDefault()
  )

  $(document).on('click', '#instructions', (e) ->
    $('.modal-header').html("<h4>Instructions</h4>")
    $('.modal-body').html("<p>Arrow Keys control the spaceship, while w-a-s-d control the block Spaceship needs to collide with the block, and the block needs to avoid the spaceship. Exiting the field of play is a loss.</p><button class = 'play btn btn-lg center-block' style = 'width: 500px;height:100px;margin-top:25px;margin-bottom:25px;border:1px solid black;'>Play Game</button>")
    e.preventDefault()
  )
)

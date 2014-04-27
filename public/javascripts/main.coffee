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

  playing: ->
    !@player.dead && !@enemy.dead

  createSprites: ->
    @sprites = []
    @score = 0

    @sprites.push new Background
    @sprites.push @player = new Player (@)
    @sprites.push @enemy = new Enemy

  initializeKeyboard: ->
    $("body").on
      'keydown': (e) ->
        if game.running && !game.enemy.dead && !game.player.dead
          e.preventDefault()
          switch e.keyCode
            when 37 then game.player.left = true
            when 38 then game.player.up = true
            when 39 then game.player.right = true
            when 40 then game.player.down = true
            when 87 then game.enemy.up = true
            when 65 then game.enemy.left = true
            when 83 then game.enemy.down = true
            when 68 then game.enemy.right = true

      'keyup': (e) ->
        if game.running
          e.preventDefault()
          switch e.keyCode
            when 37 then game.player.left = false
            when 38 then game.player.up = false
            when 39 then game.player.right = false
            when 40 then game.player.down = false
            when 87 then game.enemy.up = false
            when 65 then game.enemy.left = false
            when 83 then game.enemy.down = false
            when 68 then game.enemy.right = false

  showDeath: (isEnemy) ->
    @context.globalAlpha = 0.5
    @context.fillStyle = "#666"
    @context.fillRect(0, 0, game.canvas.width, game.canvas.height)
    @context.globalAlpha = 1.0
    @context.fillStyle = if isEnemy then "#FFFF00" else "#0000FF"
    @context.font = "bold 48px Arial"
    txt = if isEnemy then "YELLOW WINS!" else "BLUE WINS!"
    @context.fillText txt, (game.canvas.width / 2) - (@context.measureText(txt).width / 2), (game.canvas.height / 2)

class Sprite
  x: 0
  y: 0

  xVelocity: 0
  yVelocity: 0

  isEnemy: null

  imagePath: null

  constructor: ->
    @image = new Image
    @image.src = @imagePath
    @image.onload = => @ready = true
    { @width, @height } = @image

  update: (game) ->
    if game.playing() && @outOfBounds()
      @dead = true

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

    @x += @xVelocity
    @y += @yVelocity

  outOfBounds: ->
    ((@x + @width < 0) || (@x > game.canvas.width) || (@y + @height < 0) || (@y > game.canvas.height))


  draw: (context) ->
    context.drawImage(@image, @x, @y, @width, @height)
    game.showDeath(@isEnemy) if @dead

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
    @isEnemy = true

  update: (game) ->
    if @isColliding(game.player) || @dead
      @die()
    super

  die: ->
    unless @dead
      @animationSpeed = 0.3
      @images = []
      @imageIndex = 0
      for i in [1..9]
        image = new Image
        image.src = "/images/die#{i}.png"
        @images.push image
      @height = 50
      @width = 50
      @dead = true
    else
      unless @outOfBounds()
        @image = @images[Math.floor(@imageIndex)]
        @imageIndex += @animationSpeed
        @imageIndex %= @images.length

class Player extends Sprite
  imagePath: '/images/player.png'

  constructor: (game) ->
    super
    @width = 25
    @height = 25
    @isEnemy = false

    #Initial Position
    @x = game.canvas.width - @width
    @y = game.canvas.height - @height

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
    $('.modal-body').html("<p>Arrow Keys control the spaceship, while w-a-s-d control the enemy. Spaceship needs to collide with the enemy, and the enemy needs to avoid the spaceship. Exiting the field of play is a loss.</p><button class = 'play btn btn-lg center-block' style = 'width: 500px;height:100px;margin-top:25px;margin-bottom:25px;border:1px solid black;'>Play Game</button>")
    e.preventDefault()
  )
)

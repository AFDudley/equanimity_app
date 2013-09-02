fn = (Kinetic, InterfaceObject, Text, Utility) ->
  class Screen
    @screenConfigs = {}
    @registerScreen: (name, screenClass, config) ->
      # To register a screen you must call this class method
      # in the class definition AND include the file in
      # game/screens/index
      Screen.screenConfigs[name] =
        screenClass: screenClass
        config: config

    constructor: (@game, screenName, additionalOptions={}) ->
      @config = Utility.combineObjects(
        Screen.screenConfigs[screenName].config
        additionalOptions
      )
      @objects = {}
      @text = {}

    addAnimation: (image, layerName, options, finish = null) ->
      if not options.frames?
        throw new Error(
          "addAnimation called without frames specified in options.")
      animations = []
      frames = options.frames
      frameWidth = image.image.width / options.frames
      for i in [0..frames - 1]
        image.unscale()
        x = @makeScalable i * frameWidth
        x.scale()
        animations.push {
          x: x * 1
          y: 0
          width: frameWidth
          height: image.image.height
        }
      frameRate = options.frameRate ? @game.options.frameRate
      x = @makeScalable options.start.x
      y = @makeScalable options.start.y
      x.scale()
      y.scale()
      image.scale()
      sprite = new Kinetic.Sprite {
        x: x * 1
        y: y * 1
        image: image.image
        animation: 'main'
        animations: {main: animations}
        frameRate: frameRate
        scale: if options.reverse then {x: -1, y: 1} else 1
      }
      layer = @getLayer layerName
      layer.add sprite
      sprite.start()

      sprite.anim = new Kinetic.Animation(
        (frame) =>
          percent = frame.time / options.duration
          if percent >= 1
            sprite.anim.stop()
            sprite.stop()
            sprite.remove()
            finish() if finish
          else
            xDistance = options.end.x - options.start.x
            yDistance = options.end.y - options.start.y
            newX = @makeScalable options.start.x + xDistance * percent
            newY = @makeScalable options.start.y + yDistance * percent
            newX.scale()
            newY.scale()
            sprite.setPosition newX * 1, newY * 1
      )
      sprite.anim.start()

      sprite

    addImage: (imageObj, layerName, options, addTo=null) ->
      # Adds an image with the top left corner at x, y.  Note that
      # this modifies Fabric's normal functionality where it
      # places the image's center at x, y.
      # Parse options/arguments
      layer = @getLayer layerName
      
      x = @makeScalable options.x
      y = @makeScalable options.y
      z = options.z ? 1
      # Scale some objects
      x.scale()
      y.scale()
      imageObj.scale()
      imgOptions =
        x: x * 1
        y: y * 1
        z: z
        visible: options.visible ? true
        image: imageObj.image
        scale: options.scale ? 1
      # Handle cropping.
      if options.crop?
        imgOptions.crop = options.crop
        width = @makeScalable imgOptions.crop.width
        height = @makeScalable imgOptions.crop.height
        width.scale()
        height.scale()
        imgOptions.width = width * 1
        imgOptions.height = height * 1
      else
        if options.width?
          width = @makeScalable options.width
          width.scale()
          imgOptions.width = width * 1

        if options.height?
          height = @makeScalable options.height
          height.scale()
          imgOptions.height = height * 1

      # Create image
      image = new Kinetic.Image imgOptions

      if addTo
        addTo.add image
      else
        layer.add image
      image.setZIndex z
      image

    addImageFill: (imageObj, layerName, options, addTo = null) ->
      layer = @getLayer layerName
      x = @makeScalable options.x
      y = @makeScalable options.y
      width = @makeScalable options.width
      height = @makeScalable options.height
      z = options.z ? 1
      # Scale some objects
      x.scale()
      y.scale()
      width.scale()
      height.scale()
      imageObj.scale()
      fillOptions =
        x: x * 1
        y: y * 1
        width: width * 1
        height: height * 1
        fillPatternImage: imageObj.image
      fill = new Kinetic.Rect fillOptions

      if addTo
        addTo.add fill
      else
        layer.add fill

      fill.setZIndex z
      fill

    addObject: (name, layerName, options, addTo = null) ->
      objectClassName = options.objectClass ? 'default'
      objectClass = InterfaceObject.subclasses[objectClassName]
      if addTo
        objects = addTo.objects
      else
        objects = @objects
      objects[name] = new objectClass(
        this
        layerName
        options
        name
      )

    addRect: (layerName, options, addTo=null) ->
      rectOptions = $.extend {}, options
      layer = @getLayer layerName
      x = @makeScalable options.x
      y = @makeScalable options.y
      z = (if options.z? then options.z else 1) + 1
      width = @makeScalable options.width
      height = @makeScalable options.height

      x.scale()
      y.scale()
      width.scale()
      height.scale()

      rectOptions.x = x * 1
      rectOptions.y = y * 1
      rectOptions.width = width * 1
      rectOptions.height = height * 1
      # Add debug border if configured.
      if @game.options.debugRects
        rectOptions.stroke = 'green'

      rect = new Kinetic.Rect rectOptions
      if addTo
        addTo.add rect
      else
        layer.add rect
      rect.setZIndex z
      rect

    addText: (name, layerName, options, addTo=null) ->
      # x, y, size, align='center', color=null, font=null) ->
      # Adds text to the specified layer at x, y
      if addTo
        text = addTo.text
      else
        text = @text
      text[name] = new Text this, layerName, options

    cleanScreen: ->
      obj.remove() for name, obj of @text
      obj.remove() for name, obj of @objects
      @bgImage?.destroy()
      @overImage?.destroy()

    clearLayer: (layerName) ->
      layer = @getLayer layerName
      layer.clear()

    createLayer: (layerName, listening=false) ->
      @game.createLayer layerName, listening

    createScreen: ->
      # Add text
      if @config.text?
        for textName, textData of @config.text
          @addText(
            textName
            textData.layer ? 'text'
            textData
          )
      # Add objects
      if @config.objects?
        for objectName, objectData of @config.objects
          opts = $.extend {}, objectData
          if opts.imageName?
            opts.image = @game.getImage opts.imageName
          opts.layer ?= 'main'
          @addObject(
            objectName
            opts.layer
            opts
          )

    drawLayer: (layerName) ->
      layer = @getLayer layerName
      layer.draw()

    getLayer: (layerName) ->
      # Retrieves a layer from parent game.
      @game.layers[layerName]

    initialize: ->
      @cleanScreen()
      @createScreen()
      @renderScreen()

    loadData: (callback) -> callback()

    makeScalable: (value, isScaled=false) ->
      # Scales a dimension by the game's scale.
      @game.makeScalable value, isScaled

    renderScreen: -> @game.stage.draw()

    start: -> @loadData => @initialize()

  return Screen

define(
  ['kinetic'
  'kgame/core/InterfaceObject'
  'kgame/core/Text'
  'kgame/core/Utility']
  fn
)
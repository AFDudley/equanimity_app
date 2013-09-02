fn = (
  Kinetic
  Utility
  ScalableImage
  Scalable
  Screen) ->

  class Game
    constructor: (
      containerId
      callback
      inOptions
      layers = null
      stage = null) ->
      @options = $.extend {}, inOptions
      # Determine scale
      @options.defaultWidth = @options.defaultWidth
      @options.defaultHeight = (@options.defaultWidth *
        @options.heightToWidthRatio)
      @options.scale = @options.width / @options.defaultWidth
      # Determine height from width
      @options.height = @options.heightToWidthRatio * @options.width
      @data =
        images: []
      # Set up Kinetic
      if stage
        @stage = stage
      else
        @stage = new Kinetic.Stage
          container: containerId
          width: @options.width
          height: @options.height
      # Create layers
      if not layers?
        @createLayers()
      else
        @layers = layers
      # Preload all assets and then start things up.
      @finished = false
      @preloadAssets(
        =>
          callback this
          @finished = true
        @options.images
        @options.progressCallback
      )

    clearScreen: ->
      if @currentScreen?
        object.remove() for object in @currentScreen.objects
        for name, layer of @layers
          children = $.extend [], layer.getChildren()
          child.destroy() for child in children
            
        @currentScreen.objects = {}

    createLayer: (layerName, listening=false) ->
      if not @layers?
        @layers = {}
      @layers[layerName] = new Kinetic.Layer {listening: listening}
      @stage.add @layers[layerName]
      @layers[layerName]

    createLayers: ->
      # TODO: Refactor to make more general.
      @layers = {}
      @createLayer 'main', true
      @createLayer 'text'
      @createLayer 'drag'

    getAsset: (category, key) ->
      if not @cachedImages[category]?
        throw new Error "Invalid category #{category}"
      image = @cachedImages[category][key]
      if not image?
        throw new Error(
          "Could not find asset for category #{category} and key #{key}")
      @cachedImages[category][key]

    getImage: (name) ->
      image = @options.images[name]
      if not image?
        throw new Error "Could not find image with name #{name}."
      obj = image.imageObj
      obj.scale()
      obj

    getLayer: (layerName) -> @layers[layerName]

    getURLInfo: (name, formatValues = {}) ->
      # Combines various config options to generate URL
      return null if not @options.urls[name]?.url?
      url = Utility.formatString(
        @options.urls[name].url
        formatValues
      )
      method = @options.urls[name].method
      {
        url: url
        method: method
      }

    makeScalable: (value, isScaled=false) ->
      new Scalable value, @options.scale, isScaled

    preloadAssets: (
      callback
      images = @options.images
      progressCallback = null) ->
      # Loads all assets and, when the last one has been loaded,
      # executes callback.
      unloadedObjects = Utility.countObjectProperties images
      # Count up images in data.
      count = 0
      for category, images_ of @data.images
        for pk, url of images_
          count++
      unloadedObjects += count
      totalObjects = unloadedObjects
      # Number of objects to download before updating progress callback
      progressTicks = 50

      processImage = (name, data) =>
        if not data.imageObj?
          data.imageObj = new ScalableImage(
            @options.scale * (data.scale || 1)
            @options.imageDirectory + data.url
            =>
              # If there are frames, that means it's an animation.
              if data.frames
                # Animations don't work right with scaling, so we have to
                # unscale.
                data.imageObj.unscale()
                frameLength = data.imageObj.image.width / data.frames
                data.animations =
                  main: []
                for i in [0..data.frames - 1]
                  data.animations.main.push {
                    x: i * frameLength
                    y: 0
                    width: frameLength
                    height: data.imageObj.image.height
                  }
                
              if --unloadedObjects is 0
                callback this
              else if progressCallback and unloadedObjects % progressTicks is 0
                progressCallback unloadedObjects, totalObjects
          )
          data.image = data.imageObj.image
        else
          if --unloadedObjects is 0
            callback this
          else if progressCallback and unloadedObjects % progressTicks is 0
            progressCallback unloadedObjects, totalObjects
      processImage imageName, imageData for imageName, imageData of images

      # New way..
      @cachedImages = {}
      for category, images of @data.images
        @cachedImages[category] = {}
        for pk, url of images
          @cachedImages[category][pk] = new ScalableImage(
            @options.scale
            url
            =>
              if --unloadedObjects is 0
                callback this
              else if progressCallback and unloadedObjects % progressTicks is 0
                progressCallback unloadedObjects, totalObjects
          )

    removeLayer: (layerName) ->
      layer = @getLayer layerName
      layer.remove()
      delete @layers[layerName]

    sendRequest: (
      urlName
      data
      success = null
      failure = null
      formatValues = {}) ->

      cookie = $.cookie @options.authCookie
      urlInfo = @getURLInfo urlName, formatValues
      options =
        url: urlInfo.url
        method: urlInfo.method
        data: data
        dataType: 'json'
      options.success = success if success isnt null
      options.error = failure if failure isnt null
      if cookie
        options.headers = {}
        options.headers[@options.authCookie] = cookie
      $.ajax options

    setModal: (toMode = true) ->
      modalLayer = @getLayer 'modal'
      modalLayer.setListening toMode
      mainLayer = @getLayer 'main'
      mainLayer.setListening (not toMode)

    showScreen: (screenName, args...) ->
      # Clear what's there now.
      @clearScreen()
      # Get class
      screens = Screen.screenConfigs[screenName]
      screenClass = screens.screenClass
      @currentScreen = new screenClass this, screenName, args...
      @currentScreen.start()

    start: (screenName, args...) ->
      @showScreen screenName, args...

  return Game

define(
  ['kinetic'
  'kgame/core/Utility'
  'kgame/core/ScalableImage'
  'kgame/core/Scalable'
  'kgame/core/Screen']
  fn
)
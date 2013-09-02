fn = (Utility) ->
  class InterfaceObject
    @subclasses =
      default: InterfaceObject
    @registerInterfaceObject: (className, classObj) ->
      # To register an object, you must call this class method in the
      # class definition AND include the file in app/objects/index
      InterfaceObject.subclasses[className] = classObj
    # This is a class that represents an interactive object on the screen
    constructor: (@screen, @layerName, @baseOptions, @name) ->
      @game = @screen.game
      @layer = @screen.getLayer @layerName
      @initialize()
      @reset()

    activate: ->
      @show()
      @active = true

    addSnapGroup: (group, direction) ->
      # directions are "give" and "take"
      if direction is 'both'
        @addSnapGroup group, 'give'
        @addSnapGroup group, 'take'
      else if group not in @snapGroups[direction]
        @snapGroups[direction].push group

    clickHandler: (event) ->
      if @isActive() and not @isDragging()
        @trigger 'click', [event]

    createImage: ->
      if not @options.image?
        throw new Error "Trying to create image without image set."
      opts = $.extend {}, @options
      opts.x = 0
      opts.y = 0
      @kineticImage = @screen.addImage(
        @options.image
        @layerName
        opts
        @group
      )

    createObject: ->
      opts = $.extend {}, @options
      opts.x = 0
      opts.y = 0
      
      @kineticRect = @screen.addRect(
        @layerName
        opts
        @group
      )

    deactivate: ->
      @hide()
      @active = false

    dragEndHandler: ->
      @dragging = false
      dragLayer = @screen.getLayer 'drag'
      @group.moveTo @layer
      dragLayer.draw()

      for name, obj of @getOtherObjects()
        if not Utility.anyOverlap @snapGroups.give, obj.snapGroups.take
          continue
        myPos = @getCenterPosition()
        yourPos = obj.options.snapPoint ? obj.getCenterPosition()
        # Calculate distance
        distance = Utility.distanceBetweenPoints(
          myPos.x
          myPos.y
          yourPos.x
          yourPos.y
        )
        # Check to see if we're close enough
        if distance <= @game.options.snapRadius
          # Snap into place by replacing the image and hiding this one.
          @trigger 'snapReady', [obj]
          return
      @trigger 'dragStop'

    dragMoveHandler: -> (@screen.getLayer 'drag').draw()

    dragStartHandler: ->
      dragLayer = @screen.getLayer 'drag'
      @group.moveTo dragLayer
      dragLayer.draw()
      @dragging = true

    getCenterPosition: ->
      # Get the point in the middle of the object.
      coords = @kineticRect.getAbsolutePosition()
      pos =
        x: coords.x + @options.width / 2
        y: coords.y + @options.height / 2
      pos

    getDimensions: ->
      position = @getPosition()
      {
        x: position.x
        y: position.y
        width: @options.width
        height: @options.height
      }

    getOtherObjects: ->
      # Get other objects on the screen
      object for name, object of @screen.objects when object isnt this

    getPosition: ->
      position = @group.getAbsolutePosition()
      x = @screen.makeScalable position.x, true
      y = @screen.makeScalable position.y, true
      x.unscale()
      y.unscale()
      {
        x: x * 1
        y: y * 1
      }

    hide: -> @kineticImage?.hide()

    initialize: ->
      # Initialize handlers
      @initializeHandlers()
      @options = {}
      for key, value of @baseOptions
        @options[key] = value
      x = @screen.makeScalable @options.x
      y = @screen.makeScalable @options.y
      z = @layer.getZIndex() + (@options.z ? 0)
      x.scale()
      y.scale()
      @dragging = false
      @group = new Kinetic.Group {x: x * 1, y: y * 1}
      # Add handlers
      @group.on 'click', @clickHandler.bind this
      @group.on 'dragstart', @dragStartHandler.bind this
      @group.on 'dragmove', @dragMoveHandler.bind this
      @group.on 'dragend', @dragEndHandler.bind this
      @initialGroupPos = @getPosition()
      @layer.add @group
      @group.setZIndex z
      @createObject()
      @active = true
      @on(
        'dragStop'
        ->
          @reset()
          @layer.draw()
      )
      # Set up snap groups
      @initializeSnapGroups()
      if @options.snapGroups?
        for direction, groups of @options.snapGroups
          @addSnapGroup(group, direction) for group in groups

    initializeHandlers: -> @eventHandlers = {}

    initializeSnapGroups: ->
      @snapGroups =
        give: []
        take: []

    isActive: -> @active

    isDragging: -> @dragging

    isNearHome: ->
      # Returns whether or not it's within snapping distance of home.
      position = @getPosition()
      distance = Utility.distanceBetweenPoints(
        @initialGroupPos.x
        @initialGroupPos.y
        position.x
        position.y
      )
      distance < @game.options.snapRadius

    isVisible: ->
      if @kineticImage?
        return @kineticImage.isVisible()
      false

    on: (eventType, callback, reset = false) ->
      if reset or not @eventHandlers[eventType]?
        @eventHandlers[eventType] = []
      @eventHandlers[eventType].push callback

    remove: ->
      @kineticImage?.remove()
      @kineticRect?.remove()
      @group.remove()

    reset: (optionsToo=false) ->
      # Resets the object to its natural form as defined by current options.
      # Resets to original options if resetOptions = true
      @initialize() if optionsToo
      @setPosition @initialGroupPos.x, @initialGroupPos.y
      # Image

      if @options.image?
        @setImage @options.image
        @group.setDraggable @options.draggable ? false
        @show()
      else if @options.alwaysShow
        @group.setDraggable @options.draggable ? false
        @show()
      else
        @group.setDraggable false
        @hide()

    setDraggable: (value=true) ->
      @setOption 'draggable', value
      @group.setDraggable value

    setImage: (image = null) ->
      @setOption 'image', image
      if not image?
        @hide()
        return
      @createImage() if not @kineticImage?
      @kineticImage.setImage image.image
      @show()

    setImageFromName: (imageName) -> @setImage @game.getImage imageName

    setImageFromAsset: (category, pk) ->
      @setImage @screen.game.getAsset category, pk

    setOption: (key, value) -> @options[key] = value

    setPosition: (x, y) ->
      x = @screen.makeScalable x
      y = @screen.makeScalable y
      x.scale()
      y.scale()
      @group.setPosition x, y

    show: -> @kineticImage?.show()

    trigger: (eventType, functionArgs = []) ->
      @eventHandlers ?= {}
      @eventHandlers[eventType] ?= []
      for handler in @eventHandlers[eventType]
        handler.apply this, functionArgs

define(
  ['kgame/core/Utility']
  fn
)
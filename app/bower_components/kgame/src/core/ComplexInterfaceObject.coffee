fn = (InterfaceObject) ->
  class ComplexInterfaceObject extends InterfaceObject
    # Class that represents an interfaceobject that can have
    # its own sublayout of text and objects.
    addObject: (name, data) ->
      @screen.addObject name, @layerName, data, this

    addText: (name, data) ->
      @screen.addText name, @textLayerName, data, this

    hide: ->
      super
      obj.hide() for name, obj of @objects
      text.hide() for name, text of @text
      @textLayer.draw() if @textLayer?

    initialize: ->
      super
      @text = {}
      @objects = {}
      @options ?= {}
      @options.alwaysShow = @layout?.alwaysShow
      if @layout.text?
        count = 0
        while true
          name = "textLayer#{count}"
          count++
          continue if (@screen.game.getLayer name)
          break
        @textLayerName = name
        @textLayer = @screen.game.createLayer name
        @textLayer.setZIndex (@layer.getZIndex() + 1)

    remove: ->
      super
      if @screen.game.getLayer @textLayerName
        @screen.game.removeLayer @textLayerName
      @removeChildren()

    removeChildren: ->
      obj.remove() for name, obj of @objects
      text.remove() for name, text of @text

    renderLayout: ->
      if @layout.text?
        for textName, textData of @layout.text
          data = $.extend {}, textData
          position = @getPosition()
          data.x += position.x
          data.y += position.y
          if @text[textName]?
            @text[textName].remove()
          @addText textName, data

      if @layout.objects?
        for objectName, objectData of @layout.objects
          data = $.extend {}, objectData
          position = @getPosition()
          data.x += position.x
          data.y += position.y
          if @objects[objectName]?
            @objects[objectName].remove()
          @addObject objectName, data

    show: ->
      super
      @renderLayout()
      @layer.draw()
      @textLayer.draw() if @textLayer?

define(
  ['kgame/core/InterfaceObject']
  fn
)
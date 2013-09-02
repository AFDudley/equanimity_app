fn = (Kinetic) ->
  class Text
    constructor: (@screen, @layerName, @options) ->
      @layer = @screen.getLayer @layerName
      text = @options.text ? ''
      baseX = @options.x
      baseY = @options.y
      if @options.offset?
        baseX += @options.offset.x
        baseY += @options.offset.y
      x = @screen.makeScalable baseX
      y = @screen.makeScalable baseY
      z = @options.z ? 1
      size = @screen.makeScalable @options.size
      align = @options.align ? 'center'
      color = @options.color ? @screen.game.options.defaultTextColor
      font = @options.font ? @screen.game.options.defaultFont
      # Scale some quantities
      x.scale()
      y.scale()
      size.scale()
      opts = {
        x: x
        y: y
        text: text
        fontFamily: font
        fontSize: size
        fill: color
        align: align
      }
      if @options.width?
        opts.width = @screen.makeScalable @options.width
        opts.width.scale()

      @textObj = new Kinetic.Text opts
      if @options.lineHeight?
        @textObj.setLineHeight @options.lineHeight

      @layer.add @textObj
      @setText text

    getPosition: ->
      position = @textObj.getAbsolutePosition()
      x = @screen.makeScalable position.x, true
      y = @screen.makeScalable position.y, true
      x.unscale()
      y.unscale()
      {
        x: x * 1
        y: y * 1
      }

    getText: -> @textObj.getText()

    hide: -> @textObj.hide()

    isVisible: -> @textObj.isVisible()

    remove: -> @textObj.remove()

    setColor: (color) -> @textObj.setFill color

    setText: (text) ->
      centered = @textObj.getAlign() == 'center'
      if centered
        @textObj.setOffset {x: 0}
      @textObj.setText text
      if centered
        @textObj.setOffset {x: @textObj.getWidth() / 2}

    show: -> @textObj.show()

  return Text

define(
  ['kinetic']
  fn
)
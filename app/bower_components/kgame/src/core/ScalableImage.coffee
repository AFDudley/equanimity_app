fn = ->
  class ScalableImage
    # Wraps image to make it scalable
    constructor: (@myScale, url, callback = (->)) ->
      @image = new Image
      @isScaled = false
      $(@image).one 'load', callback
      @image.src = url

    scale: ->
      @image.width *= @myScale if not @isScaled
      @image.height *= @myScale if not @isScaled
      @isScaled = true
      @image

    unscale: ->
      @image.width /= @myScale if @isScaled
      @image.height /= @myScale if @isScaled
      @isScaled = false
      @image

    destroy: ->
      @image = null

  return ScalableImage

define fn

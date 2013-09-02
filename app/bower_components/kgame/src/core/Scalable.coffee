fn = ->
  class Scalable
    # This is a thin wrapper on top of floats that keeps track of
    # whether or not the dimension has been scaled.
    # It prevents double scaling.
    constructor: (value, @myScale, @isScaled=false) ->
      # Can receive either a number or another scalable.  If another
      # scalable, it will unscale and use its  value for @value.
      if value instanceof Scalable
        @isScaled = value.isScaled
        @value = value.value
      else
        @value = value

    scale: ->
      @value *= @myScale if not @isScaled
      @isScaled = true
      @value

    unscale: ->
      @value /= @myScale if @isScaled
      @isScaled = false
      @value

    valueOf: ->
      @value

  return Scalable

define fn
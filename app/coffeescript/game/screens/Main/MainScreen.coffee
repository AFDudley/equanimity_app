fn = (Screen, config) ->
  class MainScreen extends Screen
    @config: config

    createScreen: ->
      super

    renderScreen: ->
      super

define(
  ['kgame/core/Screen'
   'game/screens/Main/config']
  fn
)
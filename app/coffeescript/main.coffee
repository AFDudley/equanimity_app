libDir = '/bower_components'

requirejs.config(
  paths:
    jquery: "#{libDir}/jquery/jquery.min"
    "jquery.cookie": "#{libDir}/jquery.cookie/jquery.cookie"
    kinetic: "#{libDir}/kinetic/index"
    kgame: "#{libDir}/kgame/dist"
  shim:
    'jquery.cookie':
      deps: ['jquery']
)

requirejs(
  ['game/BTGame', 'game/settings', 'jquery', 'jquery.cookie', 'kinetic']
  (BTGame, settings) ->
    game = new BTGame(
      'gameContainer'
      (game) ->
        game.showScreen 'main'
      settings
    )
)
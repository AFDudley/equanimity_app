fn = (MainScreen) ->
  config =
    images:
      fireHex:
        url: 'fire_hex.png'
      iceHex:
        url: 'ice_hex.png'
      earthHex:
        url: 'earth_hex.png'
      windHex:
        url: 'wind_hex.png'
    defaultWidth: 1020
    width: 1020
    height: 680
    heightToWidthRatio: 2/3
    defaultTextColor: '#fff'
    defaultTextSize: 50
    animationSpeed: 7
    defaultFont: 'Verdana'
    imageDirectory: '/images/'
    debugRects: false
    authCookie: 'testToken'
    debug: true
    snapRadius: 82
    frameRate: 5
    urls:
      test:
        url: '/test/'
        method: 'POST'
    screens:
      main: MainScreen
    layers: [
      {name: 'main', listening: true}
      {name: 'text'}
      {name: 'drag'}
    ]


  config

define(
  ['game/screens/Main/MainScreen']
  fn
)
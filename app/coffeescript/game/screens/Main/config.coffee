fn = ->
  config =
    objects: {}

  qs = location.search.replace /^\?/, ""
  querySplit = qs.split "&"
  queries = {}
  for qs in querySplit
    sp = qs.split "="
    queries[sp[0]] = sp[1]
  console.log queries
  radius = queries.radius ? 8
  a = queries.a ? 32
  r = a / 2
  side = r / Math.cos(Math.PI / 6)
  h = Math.sin(Math.PI / 6) * side
  b = 2 * h + side
  start =
    x: 510
    y: 320
  qStep =
    x: b - h
    y: a / 2
  rStep =
    x: 0
    y: a
  images = ['fireHex', 'iceHex', 'earthHex', 'windHex']
  # Amount every other row is offset on the x-axis
  for q in [-radius..radius]
    for r in [-radius..radius]
      continue if Math.abs(q + r) > radius
      index = Math.ceil(Math.random() * 4) - 1
      imageName = images[index]
      config.objects["hex_#{q}_#{r}"] =
        x: q * qStep.x + r * rStep.x + start.x
        y: q * qStep.y + r * rStep.y + start.y
        width: b
        height: a
        imageName: imageName

  config

define [], fn
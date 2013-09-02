fn = ->
  class Utility
    @anyOverlap: (array1, array2) ->
      # Returns true if any element in array 1 is in array 2.
      for i in array1
        if i in array2
          return true
      false

    @combineObjects: (objects...) ->
      # Combines provided objects into a single one.
      # Later objects will take precedence over
      # earlier ones where keys conflict.
      newObject = {}
      for object in objects
        for key, value of object
          newObject[key] = value if value != null
      newObject

    @capitalize: (inStr) ->
      inStr.replace /\w\S*/g, (txt) ->
        txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

    @capitalizeFirstLetter: (inStr) ->
      inStr.charAt(0).toUpperCase() + inStr.substr(1)

    @convertUnderscoresToCamelCase: (inStr) ->
      inStr.replace(
        /([a-z])_([a-z])/g
        (g) ->
          "#{g[0]}#{g[2].toUpperCase()}"
      )

    @countInArray: (array, search) ->
      ($.grep array, (elem) -> elem is search).length

    @countObjectProperties: (object) ->
      # Counts the number of properties in an object, excluding
      # built-in ones.
      count = 0
      for prop of object
        if object.hasOwnProperty(prop)
          count++
      count

    @dictIsEmpty: (dict) ->
      for prop of dict
        if dict.hasOwnProperty prop
          return false
      true

    @distanceBetweenPoints: (x1, y1, x2, y2) ->
      Math.sqrt ((Math.pow (x2 - x1), 2) + Math.pow (y2 - y1), 2)

    @formatString: (formatStr, valueDict) ->
      newStr = formatStr
      for key, value of valueDict
        newStr = newStr.replace "{{" + key + "}}", value
      newStr

    @getRandomChoice: (array) ->
      # Gets a random item from an array.
      array[Math.floor (Math.random() * array.length)]

    @getRandomObjectChoice: (obj) ->
      keys = (key for key, prop of obj when obj.hasOwnProperty key)
      key = Utility.getRandomChoice keys
      obj[key]

    @objectsMatch: (object1, object2) ->
      # Determines whether two objects share all of the same
      # keys and values.
      for key, value of object1
        if object2[key] != value
          return false
      for key, value of object2
        if object1[key] != value
          return false
      true

    @objectReverse: (object, value) ->
      # Gets the key of the given value in an object.
      for k, v of object
        if v is value
          return k
      null

    @removeFromArray: (array, search) ->
      index = array.indexOf search
      while index isnt -1
        array.splice index, 1
        index = array.indexOf search

    @round: (value, places) ->
      i = Math.pow 10, places
      (Math.round (value * i)) / i

    @stringEndsWith: (string, search) ->
      # Checks if string ends with search.
      (string.indexOf search, string.length - search.length) != -1

    @uniqueArray: (array) ->
      # Returns a unique version of an array.
      newArray = []
      for i in array
        if not (i in newArray)
          newArray.push i
      newArray
      
  return Utility

define(
  []
  fn
)
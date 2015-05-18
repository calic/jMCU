class Output
  constructor: (@el) ->
    include this, Events

  print: (arg) ->
    @el.append arg

(do -> this).Output = Output

class Input
  constructor: (@el) ->
    include(this, Events)
    console.log @el
    @el.submit => @send arguments...
    @el.find('send').click => @send arguments...

  # handles action on the Send-Button and filters commandos
  send: (e) ->
    e.preventDefault()
    console.log @el
    cmd       = 'message'
    param    = @el.find('#message').val()

    if param.charAt(0) == '/'
      firstSpace = param.indexOf " "
      firstSpace = param.length if firstSpace == -1
      cmd = param.substr 1, firstSpace - 1
      param = param.substr firstSpace + 1, param.length

    @emit cmd, param
    @el.find('#message').val ''
    return false

(do -> this).Input = Input

class Server
  constructor: ->
    include(this, Events)

    @socket = io.connect('127.0.0.1:8000')
    @id   = undefined
    @nick = localStorage?['nickname'] || undefined
    @room = 'lobby'

    @socket.on 'message', (data) =>
      @emit data.type, data

    @socket.on 'connect', =>
      @id   = @socket.id
      @nick or= @socket.id
      @emit 'setup', @id
      @send
        type: 'who'
      $('#messages').append $('<li><i>').text "Connected as #{@nick}"

    @socket.on 'disconnect', ->
      $('#messages').append $('<li><i>').text "Disconnected from Server"

  send: (obj) ->
    obj['sender'] = @socket.id
    obj['nick'] = @nick || @socket.id
    obj['room'] = @room

    @socket.emit 'message', obj

  setnick: (nick) ->
    console.log 'setnick',  arguments
    oldnick = @nick
    @nick = nick
    localStorage?['nickname'] = nick
    @send
      type: 'nickchange'
      text: oldnick
      
(do -> this).Server = Server

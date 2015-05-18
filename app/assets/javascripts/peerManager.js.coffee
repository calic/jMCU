class PeerManager
  constructor: (@audioContext)->
    include(this, Events)
    @id             = undefined
    @nick           = localStorage?['nickname'] || undefined
    @mcu            = undefined
    @peers          = {}
    @memberList     = $ '#memberList'
    @jrumbleOptions = {x: 2, y: 2, speed: 100, rotation: 1}

  # will finish initial connection setup to Signaling-Server
  setReady: (id)->
    @id = id
    @peers[id] = new Peer id, @nick, @audioContext

  # checks if given peer is known and will add it if not
  # will setup identifier for peer and prepare peers audionodes for mixing
  addPeer: (id, nick) ->
    if id of @peers
      if nick != @peers[id].nick
        @peers[id].nick = nick
        @changePeerNick(id, nick)
      return @peers[id]
    peer = @peers[id] = new Peer id, nick, @audioContext
    @createIdentifier id, nick
    if @isMCU()
      for peerI, nodeI of @peers
        for peerJ, nodeJ of @peers
          if peerI != peerJ
            nodeI.fromPeer.connect(nodeJ.toPeer)
    return peer

  # will remove given peer from peerList
  removePeerById: (id) ->
    delete @peers[id]
    @removeIdentifier(id)

  # will remove identifiers, trash peerlist and setup a new one
  clearPeers: ->
    for peer of @peers
      @removeIdentifier(peer)
      
    delete @peers
    @peers      = {}
    @peers[@id] = new Peer @id, @nick, @audioContext

  # will return peer with given id
  findPeerById: (id) ->
    return @peers[id] or undefined

  # will return peer with given nick
  findNickById: (id) ->
    return @peers[id].nick or undefined

  # will return peer with own id
  findOwnPeer: ->
    @peers[@id]

  # will change alias of peer with given id
  changePeerNick: (id, nick) ->
    if id of @peers
      @peers[id].nick = nick
      $("[data-peer='#{id}']").find('.peer-name').text nick

  # checks if localPeer is mcu
  isMCU: ->
    @mcu == @id

  # creates identifier of localPeer
  createOwnIdentifier: ->
    peer = $(document.getElementById('peer').content.children).clone()
    peer.attr 'data-peer', @id
    peer.find('.peer-name').text @nick || @id
    peer.find('.media-object').jrumble @jrumbleOptions
    @memberList.append peer

  # creates identifier for peer with given id
  createIdentifier: (id, nick) ->
    console.log 'idintifier created'
    peer = $(document.getElementById('peer').content.children).clone()
    peer.attr 'data-peer', id
    peer.find('.peer-name').text nick || id
    peer.find('.media-object').jrumble @jrumbleOptions
    @memberList.append peer
    
  # creates tag in the identifier of peer in mcu role
  setMCUIdentifier:() ->
    mcu = $("[data-peer='#{@mcu}']")
    mcu.find('.peer-role').text 'Moderator' 
    
  # removes identifier for peer with given id
  removeIdentifier: (id) ->
    $("[data-peer='#{id}']").remove()

  # will toogle shaking avatar on voiceactivity of peer with given id
  voiceActivity: (bool, id)->
    avatar = $("[data-peer='#{id}']").find('.media-object')
    if bool then avatar.trigger("startRumble")
    else avatar.trigger("stopRumble")

(do -> this).PeerManager = PeerManager

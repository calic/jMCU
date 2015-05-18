class WebRTC
  constructor: (@peerManager, @audioContext) ->
    include(this, Events)
    @compressor               = createCompressor @audioContext, this, 10, 20, 30
    @localStream              = undefined
    @remoteId                 = undefined
    @lowpass                  = @audioContext.createBiquadFilter()
    @lowpass.type             = "lowpass"
    @lowpass.frequency.value  = 4000
    @highpass                 = @audioContext.createBiquadFilter()
    @highpass.type            = "highpass"
    @highpass.frequency.value = 400
    @lowpass.connect @highpass
    @highpass.connect(@compressor)

    @iceStorage = []
    @pc_config =
      iceServers: [
        {url: 'stun:stun.l.google.com:19302'}
        {url: "turn:numb.viagenie.ca", credential: "webrtcdemo", username: "louis%40mozilla.com"}
      ]
    @pc_constraints =
      optional: [{DtlsSrtpKeyAgreement: true}]
    @sdpConstraints =
      mandatory:
        OfferToReceiveAudio: true
        OfferToReceiveVideo: false

    getUserMedia(
      {audio: true, video: false},
      => @setupPipeline arguments... ,
      -> console.log 'An Error occured getting UserMedia'
    )

  # will setup audiopipeline if access to userMedia was granted
  setupPipeline: (stream) ->
    @localStream  = @audioContext.createMediaStreamDestination()
    @userAudio    = @audioContext.createMediaStreamSource(stream)
    @userAudio.connect(@lowpass)
    @compressor.connect(@localStream)
    @emit 'userMediaPrepared'

  # will configurate local audiopipeline for mcu needs
  setupMCU: ->
    mcu = @peerManager.findOwnPeer()
    @compressor.connect mcu.fromPeer
    mcu.toPeer.connect @audioContext.destination

  # default error callback
  fail: (data) ->
    console.log 'An Error occured', data

  # main webrtc function which sets up peerconnections,
  # initiates ice and the initial offer if localPeer is mcu
  connect: (peer) ->
    #console.log 'connect...'
    peer.pc = new RTCPeerConnection @pc_config, @pc_constraints
    if not @peerManager.isMCU()
      peer.pc.addStream(@localStream.stream)
    if @peerManager.isMCU()
      endpoint = @audioContext.createMediaStreamDestination()
      peer.toPeer.connect endpoint
      peer.pc.addStream(endpoint.stream)
    peer.pc.onaddstream = (event) =>
      remoteStream = @audioContext.createMediaStreamSource(event.stream)
      if not @peerManager.isMCU()
        remoteStream.connect(@audioContext.destination)
      if @peerManager.isMCU()
        remoteStream.connect(peer.fromPeer)
      #console.log 'onaddstream...'
    peer.pc.onicecandidate = (event) =>
      if event.candidate
        @emit 'candidate', event.candidate
    peer.pc.oniceconnectionstatechange = (event) =>
      console.log 'ICECONNECTIONSTATECHANGE', peer.pc.iceConnectionState
    @createOffer(peer) if @peerManager.isMCU()

  # will set localDescription and send the initial offer to given peer
  createOffer: (peer) ->
    #console.log 'creating offer...'
    peer.pc.createOffer ((offer) =>
      #console.log 'created offer...'
      peer.pc.setLocalDescription offer, (=>
        #console.log 'sending to remote...'
        pack = 
          recipient : peer.id
          offer     : offer
        @emit 'offer', pack 
        return
      ), -> console.log 'Error: setLocalDescription', arguments...
      return
    ), -> console.log 'Error: createOffer', arguments...
    return

  # will handle incoming offer
  # sets remote offer, creates answer, sets the localDescription and sends answer
  receiveOffer: (remoteId, offer) ->
    if not @peerManager.isMCU()
      peer = @peerManager.findPeerById(remoteId)
      #console.log 'received offer...'
      peer.pc.setRemoteDescription (new RTCSessionDescription(offer)), (=>
        #console.log 'creating answer...'
        peer.pc.createAnswer ((answer) =>
          #console.log 'created answer...'
          peer.pc.setLocalDescription answer, (=>
            #console.log 'send answer'
            pack =
              recipient : peer.id
              answer : answer
            @emit 'answer', pack
            return
          ), -> console.log 'Error: setLocalDescription', arguments...
          , @sdpConstraints
          return
        ), -> console.log 'Error: createAnswer', arguments...
        return
      ), -> console.log 'Error: setRemoteDescription', arguments...
      return

  # handles incoming answers and sets remote description
  # if sucessfull will complete ice
  receiveAnswer: (remoteId, answer) ->
    return if not @peerManager.isMCU()
    peer = @peerManager.findPeerById(remoteId)
    #console.log 'recieving answer...'
    peer.pc.setRemoteDescription new RTCSessionDescription(answer)
    for candidate in @iceStorage
      peer.pc.addIceCandidate new RTCIceCandidate candidate
      #console.log 'candidate from storage added...'

  # handles remote iceCandidates
  receiveCandidate: (remoteId, candidate) ->
    peer = @peerManager.findPeerById(remoteId)
    #console.log 'receiveCandidate...'
    if not peer.pc?.remoteDescription?
      #console.log 'ice stored...'
      @iceStorage.push candidate
    else if candidate?
      #console.log 'ice added...'
      peer.pc.addIceCandidate new RTCIceCandidate candidate
      
(do -> this).WebRTC = WebRTC

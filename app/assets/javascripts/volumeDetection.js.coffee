# Originally written by cwilso (https://github.com/cwilso)
# custom WebAudio Node which detects clipping and starts events on volume threshold violations
#
#class VolumeDetection


  # creates scriptProcess for clipping and volume detection
  #
  # @param audioContext [audioContext] audioContext this Node will be used in
  # @param clipLevel    [Float]        the suspected level of clipping
  # @param averaging    [Float]        smoothness of the detection algorithm
  # @param clipLag      [Integer]      Lag for clipping indicator to change
  #
###
createVolumeDetection1 = (audioContext, clipLevel, averaging, clipLag) ->
    volumeAudioProcess = (event) ->
        buf       = event.inputBuffer.getChannelData(0)
        bufLength = buf.length
        sum       = 0
        x         = undefined
        # Do a root-mean-square on the samples: sum up the squares...
        i = 0
        while i < bufLength
          x = buf[i]
          #if Math.abs(x) >= @clipLevel
          #  @clipping = true
          #  @lastClip = window.performance.now()
          sum += x * x
          i++
        # ... then take the square root of the sum.
        rms = Math.sqrt(sum / bufLength)
        # Now smooth this out with the averaging factor applied
        # to the previous sample - take the max here because we
        # want "fast attack, slow release."
        @volume = Math.max(rms, @volume * @averaging)


    processor = audioContext.createScriptProcessor 512
    include processor, Events

    processor.onaudioprocess = volumeAudioProcess
    processor.clipping       = false
    processor.lastClip       = 0
    processor.volume         = 0
    processor.clipLevel      = clipLevel or 0.98
    processor.averaging      = averaging or 0.95
    processor.clipLag        = clipLag or 750
    # this will have no effect, since we don't copy the input to the output,
    # but works around a current Chrome bug.
    processor.connect audioContext.destination

    requestAnimationFrame (=>
        processor.emit 'volume', processor.volume
      ), 100

    processor.checkClipping = ->
      if !@clipping
        return false
      if @lastClip + @clipLag < window.performance.now()
        @clipping = false
      @clipping

    processor.checkVolume = ->
      @volume

    processor.shutdown = ->
      @disconnect()
      @onaudioprocess = null
      return

    processor
###
createVolumeDetection2 = (audioContext, samplerate) ->
  analyser = audioContext.createAnalyser()
  analyser.fftSize = 2048
  analyser.freqByteData = new Uint8Array analyser.frequencyBinCount
  include analyser, Events

  analyser.interval = setInterval (->
    analyser.getByteFrequencyData analyser.freqByteData
    #analyser.getByteTimeDomainData analyser.freqByteData
    length = analyser.freqByteData.length

    sum = 0
    j = 0
    while j < length
      sum += analyser.freqByteData[j]
      j += 1

    analyser.volume = (sum / length)
    analyser.emit 'volume', analyser.volume

  ), samplerate

  analyser

(do -> this).createVolumeDetection2 = createVolumeDetection2

#!/usr/env coffee

fs      = require 'fs'
path    = require 'path'
http    = require 'http'
socket  = require 'socket.io'
express = require 'express'
coffee  = require 'coffee-script'

app     = express()
server  = http.Server app
io      = socket server
env     = app.get 'env'

io.on 'connection', (socket) ->

  socket.on 'message', (msg) ->
    console.log msg
    msg['sender'] = socket.id
    if msg.type == 'join'
      socket.join msg.room
    if msg.type == 'leave'
      socket.leave(msg.room)
    if msg.recipient?
      socket.to(msg.recipient).emit 'message', msg
    else
      io.to(msg.room).emit 'message', msg

  socket.on 'disconnect', ->
    io.emit 'message',
      type:'disconnect'
      sender: socket.id

  socket.join 'lobby'
  io.to('lobby').emit 'message',
    type: 'connect'
    sender: socket.id

server.listen 8000, ->
  console.log 'Server listening on http://127.0.0.1:8000/'
  console.log 'Press Ctrl-C to quit'

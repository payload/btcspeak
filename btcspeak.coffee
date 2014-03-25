#!/usr/bin/env coffee
#
# btcspeak.coffee - reads large bitcoin transactions aloud    
# Copyright (C) 2014 Gilbert `payload` Röhrbein
# Licensed GNU APGL, see `LICENSE` file

child_process   = require 'child_process'
WebSocket       = require 'ws'

main            = ->
    opts            = read_argv process.argv
    client          = new BtcSpeak opts
    client.say_text "bitcoin speak", print: true

read_argv       = (argv) ->
    url             = 'ws://ws.blockchain.info/inv'
    tts_cmd         = ["espeak"]
    i = argv.indexOf '--cmd'
    if i > -1
        tts_cmd     = argv[i+1..]
    { url, tts_cmd }

class BtcSpeak

    constructor: ({ url, @tts_cmd }) ->
        @ws         = new WebSocket url
        @ws.on 'open', @open
        @ws.on 'message', @message

    open: =>
        @ws.send '{"op":"unconfirmed_sub"}'

    message: (data, flags) =>
        data            = JSON.parse(data)
        out_sum         = sum (out.value / 100000000 for out in data.x.out)
        btc             = Math.floor out_sum
        console.log btc                 if btc > 0
        text            = ""+btc        if btc > 0
        text            = "over 9000"   if btc > 9000
        @say_text text                  if text
    
    say_text: (text, { print } = {}) =>
        cmd             = @tts_cmd.concat text
        console.log cmd[0], cmd[1..]    if print
        child_process.execFile cmd[0], cmd[1..], ->

sum             = (arr) ->
    arr.reduce (a, b) -> a + b

main()

module Irc exposing (pass, listen)

import Irc.Type as Type
import Irc.Parser exposing (parse)
import Irc.Cmd exposing (commands)

import WebSocket

pass url msg =
  case msg of
    Type.Ping data ->
      (commands url).pong data
    _ ->
      Cmd.none

listen url =
  WebSocket.listen url parse

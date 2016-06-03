module Irc exposing (process, listen) --where

import Irc.Util as Util
import Irc.Types as Types
import Irc.Parser exposing (parse)
import Irc.Commands exposing (commands)

import WebSocket

process cfg msg =
  case msg of
    Types.Ping data ->
      (commands cfg).pong data
    _ ->
      Cmd.none


listen cfg =
  WebSocket.listen (Util.url cfg) parse

module Irc exposing (process, listen) --where

{-| elm-irc library, the core component
@docs process, listen
-}

import Irc.Util as Util
import Irc.Types as Types
import Irc.Parser exposing (parse)
import Irc.Commands exposing (commands)

import WebSocket

{-| let the IRC client itself react to a particular message -}
process : Types.Config -> Types.Message -> Cmd msg
process cfg msg =
  case msg of
    Types.Ping data ->
      (commands cfg).pong data
    _ ->
      Cmd.none

{-| subscribe to IRC events -}
listen : Types.Config -> Sub Types.Message
listen cfg =
  WebSocket.listen (Util.url cfg) parse

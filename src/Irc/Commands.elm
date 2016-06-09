module Irc.Commands exposing (commands, stringify, CommandSet) --where

{-| elm-irc library, commands to be sent to the IRC server
@docs commands, stringify, CommandSet
-}

import Irc.Util as Util
import Irc.Types as Types
import WebSocket
import String

{-| a set of commands for a particular server -}
type alias CommandSet msg = {
  join : String -> Cmd msg,
  nick : String -> Cmd msg,
  raw : String -> List String -> Cmd msg,
  kick : String -> String -> Maybe String -> Cmd msg,
  register : Types.User -> Cmd msg,
  query : String -> String -> Cmd msg,
  message : String -> String -> Cmd msg,
  part : String -> Maybe String -> Cmd msg,
  pong : String -> Cmd msg,
  topic : String -> Maybe String -> Cmd msg
  }

{-| serialize individual IRC data to a raw string -}
stringify : String -> List String -> String
stringify cmd params =
  let
    addColon index str =
      if index+1 == List.length params then ":" ++ str else str
    p = List.indexedMap addColon params
  in
    cmd ++ " " ++ (String.join " " p)

push list mayb =
  case mayb of
    Nothing -> list
    Just x -> List.append list [x]

raw : Types.Config -> String -> List String -> Cmd x
raw cfg cmd params =
  WebSocket.send (Util.url cfg) (stringify cmd params)

xraw : Types.Config -> (String -> List String -> Cmd x)
xraw cfg = raw cfg

nick cfg nick' =
  raw cfg "NICK" [nick']

register cfg user =
  Cmd.batch [
    raw cfg "USER" [user.username, "0", "*", user.fullname],
    nick cfg user.nick
  ]

privmsg cfg target text =
  raw cfg "PRIVMSG" [target, text]

query cfg nick text =
  privmsg cfg nick text

message cfg channel text =
  privmsg cfg channel text

pong cfg data =
  raw cfg "PONG" [data]

join cfg channel =
  raw cfg "JOIN" [channel]

part cfg channel reason =
  raw cfg "PART" (push [channel] reason)

topic cfg channel text =
  raw cfg "TOPIC" (push [channel] text)

kick cfg channel nick reason =
  raw cfg "KICK" (push [channel] reason)

{-| generate command variants for a particular server configuration -}
commands : Types.Config -> CommandSet x
commands cfg =
  {
    raw = raw cfg,
    nick = nick cfg,
    register = register cfg,
    query = query cfg,
    message = message cfg,
    pong = pong cfg,
    join = join cfg,
    part = part cfg,
    topic = topic cfg,
    kick = kick cfg
  }

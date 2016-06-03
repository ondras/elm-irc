module Irc.Commands exposing (commands) --where

import Irc.Util as Util
import WebSocket
import String

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

raw cfg cmd params =
  WebSocket.send (Util.url cfg) (stringify cmd params)

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

module Irc.Cmd exposing (commands)

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

raw url cmd params =
  WebSocket.send url (stringify cmd params)

nick url nick' =
  raw url "NICK" [nick']

register url user =
  Cmd.batch [
    raw url "USER" [user.username, "0", "*", user.fullname],
    nick url user.nick
  ]

privmsg url target text =
  raw url "PRIVMSG" [target, text]

query url nick text =
  privmsg url nick text

message url channel text =
  privmsg url channel text

pong url data =
  raw url "PONG" [data]

join url channel =
  raw url "JOIN" [channel]

part url channel reason =
  raw url "PART" (push [channel] reason)

topic url channel text =
  raw url "TOPIC" (push [channel] text)

kick url channel nick reason =
  raw url "KICK" (push [channel] reason)

commands url =
  {
    raw = raw url,
    nick = nick url,
    register = register url,
    query = query url,
    message = message url,
    pong = pong url,
    join = join url,
    part = part url,
    topic = topic url,
    kick = kick url
  }

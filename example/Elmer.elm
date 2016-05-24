import Http
import Html
import Html.App

import Irc
import Irc.Type as Type
import Irc.Cmd

url =
  "ws://localhost:6667/?server=" ++ Http.uriEncode "irc.freenode.org"

commands = Irc.Cmd.commands url

onIrc msg =
  case Debug.log "msg" msg of
    Type.Query {from, to, text} ->
      commands.query from.nick text

    Type.Message {from, channel, text} ->
      commands.message channel text

    Type.Registered ->
      commands.join "#testik"

    _ ->
      Cmd.none

passToIrc msg cmd =
  Cmd.batch [cmd, Irc.pass url msg]

update msg x =
  (x, onIrc msg |> (passToIrc msg))

user =
  Type.User "elmer" "elmer" "Elmer Elmerovič"

main =
  Html.App.program
    {
      init = (Nothing, commands.register user),
      view = always (Html.text "..."),
      update = update,
      subscriptions = always (Irc.listen url)
    }

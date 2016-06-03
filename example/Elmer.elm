import Html

import Irc.App
import Irc.Types as Types

onIrc msg model commands =
  case Debug.log "msg" msg of
    Types.Query {from, to, text} ->
      (model, commands.query from.nick text)

    Types.Message {from, channel, text} ->
      (model, commands.message channel text)

    Types.Registered ->
      (model, commands.join "#testik")

    _ ->
      (model, Cmd.none)

user =
  Types.User "elmer" "elmer" "Elmer Elmerovič"

cfg =
  { proxy = "localhost:6667", server = "irc.freenode.org", user = user }

update _ model _ =
  (model, Cmd.none)

main =
  Irc.App.program
    {
      init = Nothing,
      cfg = cfg,
      view = always (Html.text "..."),
      onIrc = onIrc,
      update = update
    }

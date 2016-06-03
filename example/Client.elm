import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

import Irc.App
import Irc.Types as Types

type alias Model =
  {
    input : String,
    messages : List String
  }

type Msg = Input String | Send

format msg =
  case msg of
    Types.Registered -> "Registered"
    Types.Notice str -> str
    Types.Unknown str -> str
    _ -> ""

onIrc msg model commands =
  case msg of
    _ ->
      ({model | messages = (format msg) :: model.messages}, Cmd.none)

update msg model commands =
  case msg of
    Input str ->
      {model | input = str} ! [Cmd.none]

    Send ->
      let
        tokens = String.split " " model.input
        cmd = List.head tokens |> Maybe.withDefault ""
        params = List.drop 1 tokens
      in
        {model | input = ""} ! [commands.raw cmd params]

view model =
  div []
    [
      pre [] (List.map viewMessage (List.reverse model.messages)),
      input [onInput Input, value model.input] [],
      button [onClick Send] [text "Send"]
    ]

viewMessage msg =
  p [] [ text msg ]

user =
  Types.User "tester23" "tester23" "Test Testovič 23"

cfg =
  { proxy = "localhost:6667", server = "irc.freenode.org", user = user }

main = 
  Irc.App.program {
    init = Model "" [],
    cfg = cfg,
    view = view,
    onIrc = onIrc,
    update = update
  }

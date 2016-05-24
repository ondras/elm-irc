import Http
import Html exposing (..)
import Html.App exposing (program)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

import Irc
import Irc.Type as Type
import Irc.Cmd

type alias Model =
  {
    input : String,
    messages : List String
  }

type Msg
  = Input String
  | Send
  | IrcMsg Type.Msg

url =
  "ws://localhost:6667/?server=" ++ Http.uriEncode "irc.freenode.org"

commands = Irc.Cmd.commands url

format msg =
  case msg of
    Type.Registered -> "Registered"
    Type.Notice str -> str
    Type.Unknown str -> str
    _ -> ""

onIrc msg model =
  case Debug.log "onIrc" msg of
    _ ->
      ({model | messages = (format msg) :: model.messages}, Cmd.none)

passToIrc msg (model, cmd) =
  (model, Cmd.batch [cmd, Irc.pass url msg])

update msg model =
  case Debug.log "update" msg of
    Input str ->
      {model | input = str} ! [Cmd.none]

    Send ->
      let
        tokens = String.split " " model.input
        cmd = List.head tokens |> Maybe.withDefault ""
        params = List.drop 1 tokens
      in
        {model | input = ""} ! [commands.raw cmd params]

    IrcMsg msg ->
      onIrc msg model |> (passToIrc msg)

view : Model -> Html Msg
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
  Type.User "tester" "tester" "Test Testovič"

main =
  program
    { init = (Model "" [], commands.register user)
    , view = view
    , update = update
    , subscriptions = always ((Sub.map IrcMsg) (Irc.listen url))
    }

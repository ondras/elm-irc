module Irc.App exposing (program) --where

{-| elm-irc client library, the Elm Architecture wrapper
@docs program
-}

import Html
import Html.App
import Irc
import Irc.Commands exposing (commands, CommandSet)
import Irc.Types as Types

type Msg x = IrcMsg Types.Message | AppMsg x

merge (model, cmd1) cmd2 =
  (model, Cmd.batch [cmd1, cmd2])

{-| A specilized version of `Html.App.program` that features the extra `onIrc` callback -}
program : {
    cfg : Types.Config,
    init : model,
    onIrc : Types.Message -> model -> CommandSet (Msg x) -> (model, Cmd (Msg x)),
    update : x -> model -> CommandSet (Msg x) -> (model, Cmd (Msg x)),
    view : model -> Html.Html x
  } -> Program Never
program app =
  let
    cmds = (commands app.cfg)
    update msg model =
      case msg of
        IrcMsg msg ->
          merge (app.onIrc msg model cmds) (Irc.process app.cfg msg)
        AppMsg x ->
          app.update x model cmds
    subscriptions = always ((Sub.map IrcMsg) (Irc.listen app.cfg))
    init = (app.init, cmds.register app.cfg.user)
    view model =
      Html.App.map AppMsg (app.view model)

  in
    Html.App.program {
      init = init,
      update = update,
      subscriptions = subscriptions,
      view = view
    }

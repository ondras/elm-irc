module CommandsTests exposing (all)

import ElmTest exposing (..)
import Irc.Commands exposing (stringify)
import Irc.Types

all =
  suite "Commands" [
    command
  ]

command =
  let
    expected = "TEST a :b c d"
    actual = stringify "TEST" ["a", "b c d"]
  in
   assertEqual expected actual |> test "Command with arguments"

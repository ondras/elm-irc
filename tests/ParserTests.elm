module ParserTests exposing (all)

import ElmTest exposing (..)
import Irc.Parser exposing (parse)
import Irc.Types

all =
  suite "Parser" [
    unknown,
    ping
  ]

unknown =
  let
    str = "wtfomglol"
    expected = Irc.Types.Unknown str
    actual = parse str
  in
   assertEqual expected actual |> test "Unknown"

ping =
  let
    str = "xxx"
    expected = Irc.Types.Ping str
    actual = parse ("PING " ++ str)
  in
   assertEqual expected actual |> test "Ping"

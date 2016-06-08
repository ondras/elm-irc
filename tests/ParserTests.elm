module ParserTests exposing (all)

import ElmTest exposing (..)
import Irc.Parser exposing (parse)
import Irc.Types

all =
  suite "Parser" [
    unknown
  ]

unknown =
  let
    str = "wtfomglol"
    expected = Irc.Types.Unknown str
    actual = parse str
  in
   assertEqual expected actual |> test "Unknown"

import ElmTest exposing (..)

import ParserTests

tests = suite "elm-irc" [
    ParserTests.all
  ]

main = runSuite tests

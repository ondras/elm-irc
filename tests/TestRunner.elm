import ElmTest exposing (..)

import ParserTests
import CommandsTests

tests = suite "elm-irc" [
    ParserTests.all,
    CommandsTests.all
  ]

main = runSuite tests

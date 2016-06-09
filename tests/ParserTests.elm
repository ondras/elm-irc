module ParserTests exposing (all)

import ElmTest exposing (..)
import Irc.Parser exposing (parse)
import Irc.Types

all =
  suite "Parser" [
    source,
    multiword,
    unknown,
    ping,
    notice,
    registered,
    nick,
    join,
    part,
    kick,
    privmsg
  ]

sample = "wtf omg lol"

source =
  let
    expected = Irc.Types.Notice sample
    actual = parse (":blah NOTICE " ++ sample)
  in
   assertEqual expected actual |> test "Notice with source"

multiword =
  let
    expected = Irc.Types.Notice sample
    actual = parse ("NOTICE :" ++ sample)
  in
   assertEqual expected actual |> test "Notice with colon"

unknown =
  let
    expected = Irc.Types.Unknown sample
    actual = parse sample
  in
   assertEqual expected actual |> test "Unknown"

ping =
  let
    expected = Irc.Types.Ping sample
    actual = parse ("PING " ++ sample)
  in
   assertEqual expected actual |> test "Ping"

notice =
  let
    expected = Irc.Types.Notice sample
    actual = parse ("NOTICE " ++ sample)
  in
   assertEqual expected actual |> test "Notice"

registered =
  let
    expected = Irc.Types.Registered
    actual = parse ("004 " ++ sample)
  in
   assertEqual expected actual |> test "Registered"

nick =
  let
    expected = Irc.Types.Nick { who = Irc.Types.User "a" "b" "c", nick = "d" }
    actual = parse ":a!b@c NICK d"
  in
   assertEqual expected actual |> test "Nick"

join =
  let
    expected = Irc.Types.Joined { who = Irc.Types.User "a" "b" "c", channel = "#d" }
    actual = parse ":a!b@c JOIN #d"
  in
   assertEqual expected actual |> test "Join"

part = suite "Part" [ partWithReason, partWithoutReason ]

partWithReason =
  let
    expected = Irc.Types.Parted { who = Irc.Types.User "a" "b" "c", channel = "#d", reason = Just "reason" }
    actual = parse ":a!b@c PART #d reason"
  in
   assertEqual expected actual |> test "Part with reason"

partWithoutReason =
  let
    expected = Irc.Types.Parted { who = Irc.Types.User "a" "b" "c", channel = "#d", reason = Nothing }
    actual = parse ":a!b@c PART #d"
  in
   assertEqual expected actual |> test "Part without reason"

kick = suite "Kick" [ kickWithReason, kickWithoutReason ]

kickWithReason =
  let
    expected = Irc.Types.Kicked {
      who = Irc.Types.User "a" "b" "c",
      whom = "d",
      channel = "#xxx",
      reason = Just "reason"
    }
    actual = parse ":a!b@c KICK #xxx d reason"
  in
   assertEqual expected actual |> test "Kick with reason"

kickWithoutReason =
  let
    expected = Irc.Types.Kicked {
      who = Irc.Types.User "a" "b" "c",
      whom = "d",
      channel = "#xxx",
      reason = Nothing
    }
    actual = parse ":a!b@c KICK #xxx d"
  in
   assertEqual expected actual |> test "Kick without reason"

privmsg = suite "Privmsg" [ message, query ]

message =
  let
    expected = Irc.Types.Message { from = Irc.Types.User "a" "b" "c", channel = "#d", text = sample }
    actual = parse (":a!b@c PRIVMSG #d " ++ sample)
  in
   assertEqual expected actual |> test "Message"

query =
  let
    expected = Irc.Types.Query { from = Irc.Types.User "a" "b" "c", to = "d", text = sample }
    actual = parse (":a!b@c PRIVMSG d " ++ sample)
  in
   assertEqual expected actual |> test "Query"

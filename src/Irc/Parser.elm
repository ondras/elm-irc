module Irc.Parser exposing (parse)

import Irc.Type as Type
import Regex
import Array
import String

type alias Tokens = {
  prefix : Maybe String,
  command : Maybe String,
  params : List String
}

pattern = {
    message = Regex.regex "^(:(\\S+) )?(\\S+)( (.+))?$",
    user = Regex.regex "^(.*)!(.*)@(.*)$",
    target = Regex.regex "^(\\S+) :(.*)$"
  }

matchToArray regex str =
  let
    m = Regex.find Regex.All regex str
  in
    case List.head m of
      Nothing ->
        Array.fromList []

      Just m ->
        Array.fromList m.submatches


getMatch index matches =
  Array.get index matches
    |> Maybe.withDefault (Just "")
    |> Maybe.withDefault ""

parsePrivmsg tokens =
  let
    sender = parseUser (Maybe.withDefault "" tokens.prefix)
    name = List.head tokens.params |> Maybe.withDefault ""
    content = List.drop 1 tokens.params |> String.join " "
  in
    if String.startsWith "#" name then
      Type.Message {
        from = sender, channel = name, text = content
        }
    else
      Type.Query {
        from = sender, to = name, text = content
      }

parseUser str =
  let parts = matchToArray pattern.user str
  in Type.User (getMatch 0 parts) (getMatch 1 parts) (getMatch 2 parts)

toParams str =
  let
    splitted = Regex.split (Regex.AtMost 1) (Regex.regex "(^| ):") str
    first = Maybe.withDefault "" (List.head splitted)
    second = List.head (List.drop 1 splitted)
    params = if first == "" then [] else String.split " " first
  in
    case second of
      Nothing -> params
      Just last -> params ++ [last]

tokenize source parts =
  let
    command = List.head parts
    str = String.join " " (List.drop 1 parts)
  in
    Tokens source command (toParams str)

toTokens str =
  let
    parts = String.split " " str
    firstPart = List.head parts |> Maybe.withDefault ""
    remainingParts = List.drop 1 parts

  in
    if String.startsWith ":" firstPart then
      tokenize (String.dropLeft 1 firstPart |> Just) remainingParts
    else
      tokenize Nothing parts

parse str =
  let
    tokens = toTokens str
  in
    case tokens.command of
      Just "PING" ->
        Type.Ping (String.join " " tokens.params)

      Just "NOTICE" ->
        Type.Notice (String.join " " tokens.params)

      Just "PRIVMSG" ->
        parsePrivmsg tokens

      Just "004" ->
        Type.Registered

      Just "NICK" ->
        let sender = parseUser (Maybe.withDefault "" tokens.prefix)
        in Type.Nick {who = sender, nick = String.join " " tokens.params}

      Just "JOIN" ->
        let sender = parseUser (Maybe.withDefault "" tokens.prefix)
        in Type.Joined {who = sender, channel = String.join " " tokens.params}

      Just "PART" ->
        let
          sender = parseUser (Maybe.withDefault "" tokens.prefix)
          channel = List.head tokens.params
        in Type.Parted {who = sender, channel = Maybe.withDefault "" channel, reason = List.head tokens.params}

      Just "KICK" ->
        let
          sender = parseUser (Maybe.withDefault "" tokens.prefix)
          channel = List.head tokens.params
          whom = List.head (List.drop 1 tokens.params)
        in Type.Kick {
          who = sender,
          whom = Maybe.withDefault "" whom,
          channel = Maybe.withDefault "" channel,
          reason = List.head (List.drop 2 tokens.params)
        }

      Just "TOPIC" ->
        let
          sender = parseUser (Maybe.withDefault "" tokens.prefix)
          channel = List.head tokens.params
        in Type.Topic {who = sender, channel = Maybe.withDefault "" channel, text = List.head tokens.params}

      _ ->
        Type.Unknown str

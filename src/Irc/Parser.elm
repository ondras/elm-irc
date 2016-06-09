module Irc.Parser exposing (parse) --where

import Irc.Types as Types
import Regex
import Array
import String

type alias Tokens = {
  prefix : Maybe String,
  command : Maybe String,
  params : List String
}

getMatch : Int -> Array.Array (Maybe String) -> String
getMatch index matches =
  Array.get index matches
    |> Maybe.withDefault (Just "")
    |> Maybe.withDefault ""

matchToArray : Regex.Regex -> String -> Array.Array (Maybe String)
matchToArray regex str =
  let
    m = Regex.find Regex.All regex str
  in
    case List.head m of
      Nothing ->
        Array.fromList []

      Just m ->
        Array.fromList m.submatches

parsePrivmsg : Tokens -> Types.Message
parsePrivmsg tokens =
  let
    sender = toUser (Maybe.withDefault "" tokens.prefix)
    name = List.head tokens.params |> Maybe.withDefault ""
    content = List.drop 1 tokens.params |> String.join " "
  in
    if String.startsWith "#" name then
      Types.Message {
        from = sender, channel = name, text = content
        }
    else
      Types.Query {
        from = sender, to = name, text = content
      }

toUser : String -> Types.User
toUser str =
  let parts = matchToArray (Regex.regex "^(.*)!(.*)@(.*)$") str
  in Types.User (getMatch 0 parts) (getMatch 1 parts) (getMatch 2 parts)

splitParams : String -> List String
splitParams str =
  let
    splitted = Regex.split (Regex.AtMost 1) (Regex.regex "(^| ):") str
    first = Maybe.withDefault "" (List.head splitted)
    second = List.head (List.drop 1 splitted)
    params = if first == "" then [] else String.split " " first
  in
    case second of
      Nothing -> params
      Just last -> params ++ [last]

toTokens : Maybe String -> (List String)-> Tokens
toTokens source parts =
  let
    command = List.head parts
    str = String.join " " (List.drop 1 parts)
  in
    Tokens source command (splitParams str)

tokenize : String -> Tokens
tokenize str =
  let
    parts = String.split " " str
    firstPart = List.head parts |> Maybe.withDefault ""
    remainingParts = List.drop 1 parts

  in
    if String.startsWith ":" firstPart then
      toTokens (String.dropLeft 1 firstPart |> Just) remainingParts
    else
      toTokens Nothing parts

parse : String -> Types.Message
parse str =
  let
    tokens = tokenize str
  in
    case tokens.command of
      Just "PING" ->
        Types.Ping (String.join " " tokens.params)

      Just "NOTICE" ->
        Types.Notice (String.join " " tokens.params)

      Just "PRIVMSG" ->
        parsePrivmsg tokens

      Just "004" ->
        Types.Registered

      Just "NICK" ->
        let sender = toUser (Maybe.withDefault "" tokens.prefix)
        in Types.Nick {who = sender, nick = String.join " " tokens.params}

      Just "JOIN" ->
        let sender = toUser (Maybe.withDefault "" tokens.prefix)
        in Types.Joined {who = sender, channel = String.join " " tokens.params}

      Just "PART" ->
        let
          sender = toUser (Maybe.withDefault "" tokens.prefix)
          channel = List.head tokens.params
        in Types.Parted {who = sender, channel = Maybe.withDefault "" channel, reason = tokens.params |> List.drop 1 |> List.head}

      Just "KICK" ->
        let
          sender = toUser (Maybe.withDefault "" tokens.prefix)
          channel = List.head tokens.params
          whom = List.head (List.drop 1 tokens.params)
        in Types.Kicked {
          who = sender,
          whom = Maybe.withDefault "" whom,
          channel = Maybe.withDefault "" channel,
          reason = List.head (List.drop 2 tokens.params)
        }

      Just "TOPIC" ->
        let
          sender = toUser (Maybe.withDefault "" tokens.prefix)
          channel = List.head tokens.params
        in Types.Topic {who = sender, channel = Maybe.withDefault "" channel, text = List.head tokens.params}

      _ ->
        Types.Unknown str

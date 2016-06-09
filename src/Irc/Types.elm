module Irc.Types exposing (..) --where

type alias User
  = {
    nick : String,
    username : String,
    fullname : String
  }

type Message
  = Unknown String
  | Ping String
  | Notice String
  | Query {
      from : User,
      to : String,
      text : String
    }
  | Message {
      from : User,
      channel : String,
      text : String
    }
  | Registered
  | Joined {
      who : User,
      channel : String
    }
  | Parted {
      who : User,
      channel : String,
      reason : Maybe String
    }
  | Topic {
      who : User,
      channel : String,
      text : Maybe String
    }
  | Nick {
      who : User,
      nick : String
    }
  | Kicked {
      who : User,
      whom: String,
      channel : String,
      reason : Maybe String
    }

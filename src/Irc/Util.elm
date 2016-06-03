module Irc.Util exposing (..) --where

import Http

url cfg =
  "ws://" ++ cfg.proxy ++ "/?server=" ++ Http.uriEncode cfg.server


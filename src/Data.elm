module Data exposing (Token, tokenDecoder)

import Json.Decode exposing (..)


type alias Token =
    String


tokenDecoder =
    string

-- Copyright 2019 Jeremy H. Brown


port module Ports exposing (clearToken, storeToken)

import Data
import Json.Decode as Decode
import Json.Encode as Encode


port clearToken : () -> Cmd msg


port storeToken : Data.Token -> Cmd msg

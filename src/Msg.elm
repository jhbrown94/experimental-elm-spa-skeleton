-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Msg exposing (MainMsg(..), Msg(..))

import Browser exposing (UrlRequest)
import Msg.Page.Login as Login
import Route exposing (Route)
import Url exposing (Url)


type Msg
    = Main MainMsg
    | Login Login.Msg


type MainMsg
    = NoEvent
    | Logout
    | PushRoute Route
    | UrlChanged Url
    | UrlRequested UrlRequest

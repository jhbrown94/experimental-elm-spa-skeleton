-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Msg exposing (Msg(..))

import Browser exposing (UrlRequest)
import PageMsg exposing (PageMsg)
import Session
import Url exposing (Url)


type Msg
    = NoEvent
    | UrlRequested UrlRequest
    | UrlChanged Url
    | Page PageMsg
    | Session Session.Msg

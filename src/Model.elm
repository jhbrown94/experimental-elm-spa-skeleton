-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Model exposing (Model, wrapPage)

import Msg
import Page
import PageMsg exposing (PageMsg)
import Session exposing (Session)


type alias Model =
    { session : Session
    , page : Page.Model PageMsg
    }


wrapPage ( session, pageModel, cmd ) =
    ( Model session pageModel, Cmd.map Msg.Page cmd )

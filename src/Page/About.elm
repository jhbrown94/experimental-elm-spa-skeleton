-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.About exposing (Model, Msg, init, update, view)

import Element
    exposing
        ( spacing
        , text
        , wrappedRow
        )
import Route
import Session exposing (Session)
import ViewHelpers exposing (..)


type alias Model =
    ()


type alias Msg =
    ()


init : Session -> ( Session, Model, Cmd Msg )
init session =
    ( session, (), Cmd.none )


view session model =
    { title = "About"
    , body =
        [ dialogPage <|
            wrappedRow
                [ spacing 10 ]
                [ text "This page is all about this app" ]
        ]
    }


update msg session model =
    ( session, model, Cmd.none )

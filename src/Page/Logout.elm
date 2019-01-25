-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.Logout exposing (init)

import Element
    exposing
        ( spacing
        , text
        , wrappedRow
        )
import Msg exposing (Msg(..))
import Page
import Route
import ViewHelpers exposing (..)


init =
    ( Page.withNoSession view update { title = pageTitle "Logout", state = () }
    , Cmd.none
    )


view data model =
    dialogPage <|
        wrappedRow
            [ spacing 10 ]
            [ text "You have logged out"
            , button [] { onPress = Just <| Msg.Main <| Msg.PushRoute Route.Root, label = text "Return home" }
            ]


update builder data msg model =
    ( model, Cmd.none )

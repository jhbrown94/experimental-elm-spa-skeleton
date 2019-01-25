-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.Secondary exposing (init)

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


init session =
    ( Page.withSession view update { title = pageTitle "Secondary", session = session, state = () }
    , Cmd.none
    )


view data model =
    dialogPage <|
        wrappedRow
            [ spacing 10 ]
            [ text "This is a secondary page"
            , text <| "Session user's username is: " ++ data.session.username
            , button [] { onPress = Just <| Msg.Main <| Msg.PushRoute Route.Root, label = text "Primary" }
            , aboutButton
            , logoutButton model
            , button [] { onPress = Just <| Msg.Main <| Msg.PushRoute (Route.Login Nothing), label = text "Log in - inappropriately" }
            ]


update builder data msg model =
    ( model, Cmd.none )

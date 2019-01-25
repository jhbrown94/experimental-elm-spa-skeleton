-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.Primary exposing (init)

import Element
    exposing
        ( column
        , spacing
        , text
        )
import Model exposing (Model)
import Msg exposing (Msg)
import Page exposing (Page)
import Route
import Session exposing (Session)
import ViewHelpers exposing (..)


init : Session -> ( Page Session Msg Model, Cmd Msg.Msg )
init session =
    ( Page.withSession view update { title = pageTitle "Primary", session = session, state = () }
    , Cmd.none
    )


view : Page.ViewWithSession Session () Msg Model
view data model =
    dialogPage <|
        column
            [ spacing 10 ]
            [ text <| "Session user's username is: " ++ data.session.username
            , text "This is a primary page"
            , button [] { onPress = Just <| Msg.Main <| Msg.PushRoute Route.Secondary, label = text "Secondary" }
            , aboutButton
            , logoutButton model
            ]


update builder data msg model =
    ( model, Cmd.none )

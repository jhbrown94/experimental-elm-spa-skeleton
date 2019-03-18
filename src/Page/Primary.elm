-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.Primary exposing (Model, Msg, init, update, view)

import Browser exposing (Document)
import Element
    exposing
        ( column
        , spacing
        , text
        )
import Route
import Session exposing (Session)
import ViewHelpers exposing (..)


type alias Model =
    ()


type Msg
    = LogoutPressed
    | AboutPressed
    | SecondaryPressed


init : Session -> ( Session, Model, Cmd Msg )
init session =
    ( session, (), Cmd.none )


view : Session -> Model -> Document Msg
view session model =
    { title = "Primary"
    , body =
        [ dialogPage <|
            column
                [ spacing 10 ]
                [ text <| "Auth token is: " ++ Debug.toString session.authToken
                , text "This is a primary page"
                , button [] { onPress = Just SecondaryPressed, label = text "Secondary" }
                , aboutButton AboutPressed
                , logoutButton LogoutPressed session
                ]
        ]
    }


update : Msg -> Session -> Model -> ( Session, Model, Cmd Msg )
update msg session model =
    case msg of
        LogoutPressed ->
            ( session, model, Route.push Route.Logout session.nav )

        AboutPressed ->
            ( session, model, Route.push Route.About session.nav )

        SecondaryPressed ->
            ( session, model, Route.push Route.Secondary session.nav )

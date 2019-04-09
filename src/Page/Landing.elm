-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.Landing exposing (Model, Msg, init, update, view)

import Browser exposing (Document)
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


type Msg
    = LoginPressed
    | AboutPressed


init : Session -> ( Session, Model, Cmd Msg )
init session =
    ( session, (), Cmd.none )


view : Session -> Model -> Document Msg
view session model =
    { title = "Landing"
    , body =
        [ dialogPage <|
            wrappedRow
                [ spacing 10 ]
                [ button [] { onPress = Just LoginPressed, label = text "Log in" }

                --, button [] { onPress = Nothing, label = text "Sign up" }
                , aboutButton AboutPressed
                ]
        ]
    }


update : Msg -> Session -> Model -> ( Session, Model, Cmd Msg )
update msg session model =
    case msg of
        LoginPressed ->
            ( session |> Session.navPush (Route.Login Nothing), model, Cmd.none )

        AboutPressed ->
            ( session |> Session.navPush Route.About, model, Cmd.none )

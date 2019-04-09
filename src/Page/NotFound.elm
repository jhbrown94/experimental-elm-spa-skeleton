-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.NotFound exposing (Model, Msg, init, update, view)

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
    { notFoundUrl : String }


type Msg
    = HomePressed


init : String -> Session -> ( Session, Model, Cmd Msg )
init notFoundUrl session =
    ( session, { notFoundUrl = notFoundUrl }, Cmd.none )


view : Session -> Model -> Document Msg
view session model =
    { title = "Not found"
    , body =
        [ dialogPage <|
            column
                [ spacing 10 ]
                [ text "URL not found:"
                , text model.notFoundUrl
                , button [] { onPress = Just HomePressed, label = text "Go to home" }
                ]
        ]
    }


update : Msg -> Session -> Model -> ( Session, Model, Cmd Msg )
update msg session model =
    case msg of
        HomePressed ->
            ( session |> Session.navPush Route.Root, model, Cmd.none )

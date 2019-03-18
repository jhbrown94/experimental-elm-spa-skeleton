-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.Secondary exposing (Model, Msg, init, update, view)

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
    = PrimaryPressed
    | LoginPressed
    | AboutPressed
    | LogoutPressed


init : Session -> ( Session, Model, Cmd Msg )
init session =
    ( session, (), Cmd.none )


view : Session -> Model -> Document Msg
view session model =
    { title = "Secondary"
    , body =
        [ dialogPage <|
            wrappedRow
                [ spacing 10 ]
                [ text "This is a secondary page"
                , text <| "Session user's authtoken is: " ++ Debug.toString session.authToken
                , button [] { onPress = Just PrimaryPressed, label = text "Primary" }
                , aboutButton AboutPressed
                , logoutButton LogoutPressed session
                , button [] { onPress = Just LoginPressed, label = text "Log in - inappropriately" }
                ]
        ]
    }


update : Msg -> Session -> Model -> ( Session, Model, Cmd Msg )
update msg session model =
    case msg of
        PrimaryPressed ->
            ( session, model, Route.push Route.Root session.nav )

        LoginPressed ->
            ( session, model, Route.push (Route.Login Nothing) session.nav )

        LogoutPressed ->
            ( session, model, Route.push Route.Logout session.nav )

        AboutPressed ->
            ( session, model, Route.push Route.About session.nav )

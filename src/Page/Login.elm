-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.Login exposing (Model, Msg, init, update, view)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Element
    exposing
        ( Element
        , alignRight
        , centerX
        , centerY
        , column
        , el
        , fill
        , padding
        , rgb255
        , row
        , spacing
        , text
        , width
        , wrappedRow
        )
import Element.Font as Font
import Element.Input as Input
import Route
import Session exposing (Session)
import Url exposing (Url)
import ViewHelpers exposing (..)


type alias Model =
    { username : String
    , rawPassword : String
    , destination : Route.Destination
    }


type Msg
    = UsernameChanged String
    | PasswordChanged String
    | LoginPressed
    | CancelPressed


initModel : Model
initModel =
    { username = ""
    , rawPassword = ""
    , destination = Route.Root
    }


init : Maybe String -> Session -> ( Session, Model, Cmd Msg )
init successUrl session =
    let
        destination =
            successUrl
                |> Maybe.andThen Url.fromString
                |> Maybe.map Route.parseUrl
                |> Maybe.withDefault Route.Root

        cmd =
            case session.authToken of
                Nothing ->
                    Cmd.none

                Just _ ->
                    Route.replace destination session.nav
    in
    ( session, { initModel | destination = destination }, cmd )


update : Msg -> Session -> Model -> ( Session, Model, Cmd Msg )
update msg session model =
    case msg of
        UsernameChanged username ->
            ( session, { model | username = username }, Cmd.none )

        PasswordChanged password ->
            ( session, { model | rawPassword = password }, Cmd.none )

        LoginPressed ->
            ( { session | authToken = Just model.username }
            , model
            , Route.replace model.destination session.nav
            )

        CancelPressed ->
            ( session, model, Navigation.back session.nav.key 1 )


view : Session -> Model -> Document Msg
view session model =
    { title = "Login"
    , body =
        [ dialogPage <|
            wrappedRow
                [ spacing 10 ]
                [ Input.username
                    [ Font.color black
                    ]
                    { onChange = UsernameChanged
                    , text = model.username
                    , placeholder = Just <| Input.placeholder [] (text "your.username")
                    , label = Input.labelBelow [] (text "Username")
                    }
                , Input.currentPassword
                    [ Font.color black
                    ]
                    { onChange = PasswordChanged
                    , text = model.rawPassword
                    , placeholder = Just <| Input.placeholder [] (text "password")
                    , label = Input.labelBelow [] (text "Password")
                    , show = False
                    }
                , button [] { onPress = Just LoginPressed, label = text "Log in" }
                , button [] { onPress = Just CancelPressed, label = text "Cancel" }
                ]
        ]
    }

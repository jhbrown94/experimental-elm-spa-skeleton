-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page.Login exposing (init)

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
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Msg.Page.Login exposing (..)
import Page
import Session exposing (Session)
import Url
import ViewHelpers exposing (..)


type alias State =
    { username : String

    --, rawPassword : String
    , successUrlString : String
    }


initState : State
initState =
    { username = ""

    --, rawPassword = ""
    , successUrlString = "/"
    }


init session successUrl model =
    let
        urlString =
            successUrl |> Maybe.map Url.toString |> Maybe.withDefault "/"

        cmd =
            case session of
                Nothing ->
                    Cmd.none

                Just s ->
                    Navigation.replaceUrl model.key urlString
    in
    ( Page.withOptionalSession view
        update
        { title = pageTitle "Login", session = session, state = { initState | successUrlString = urlString } }
    , cmd
    )


update : Page.UpdateWithOptionalSession Session State Msg.Msg Model
update builder ({ state } as oldData) msg model =
    let
        advancePage newState =
            Model.updatePageInPlace
                (Page.updateWithOptionalSession
                    { oldData | state = newState }
                    builder
                )
                model
    in
    case msg of
        Msg.Login loginMsg ->
            case loginMsg of
                UsernameChanged username ->
                    ( advancePage { state | username = username }, Cmd.none )

                --PasswordChanged password ->
                --   ( advancePage { state | rawPassword = password }, Cmd.none )
                LoginPressed ->
                    ( model
                        |> Model.updatePageInPlace
                            (Page.updateWithOptionalSession { oldData | session = Just { username = state.username } }
                                builder
                            )
                    , Navigation.replaceUrl model.key state.successUrlString
                    )

                CancelPressed ->
                    ( model, Navigation.back model.key 1 )

        _ ->
            ( model, Cmd.none )


view : Page.ViewWithOptionalSession Session State Msg.Msg Model
view { state } model =
    dialogPage <|
        wrappedRow
            [ spacing 10 ]
            [ Input.username
                [ Font.color black
                ]
                { onChange = Msg.Login << UsernameChanged
                , text = state.username
                , placeholder = Just <| Input.placeholder [] (text "your.username")
                , label = Input.labelBelow [] (text "Username")
                }

            {- , Input.currentPassword
               [ Font.color black
               ]
               { onChange = PasswordChanged
               , text = state.rawPassword
               , placeholder = Just <| Input.placeholder [] (text "password")
               , label = Input.labelBelow [] (text "Password")
               , show = False
               }
            -}
            , button [] { onPress = Just <| Msg.Login LoginPressed, label = text "Log in" }
            , button [] { onPress = Just <| Msg.Login CancelPressed, label = text "Cancel" }
            ]

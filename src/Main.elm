-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation
import Data
import Descriptors exposing (landingDescriptor)
import Html
import Json.Decode as Decode
import Model exposing (Model)
import Msg exposing (..)
import Page as Page
import Page.Landing as Landing
import Route exposing (Destination(..))
import Router
import Session exposing (Session)
import Url exposing (Url)


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }


type alias Flags =
    ()


init : Decode.Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init jsonFlags url key =
    let
        session =
            Session.init key url Nothing
    in
    session
        |> Router.route url
        |> Model.wrapPage
        |> (\( m, c ) -> ( m, c, Nothing ))
        |> runSessionCommands


view : Model -> Document Msg
view { session, page } =
    let
        { title, body } =
            Page.view session page
    in
    { title = title, body = body |> List.map (Html.map Page) }


mainUpdate : Msg -> Model -> ( Model, Cmd Msg, Maybe Session.Event )
mainUpdate msg ({ session, page } as model) =
    case msg of
        NoEvent ->
            ( model, Cmd.none, Nothing )

        UrlRequested (Internal url) ->
            ( { model
                | session =
                    model.session
                        |> Session.navPushUrl (Url.toString url)
              }
            , Cmd.none
            , Nothing
            )

        UrlRequested (External urlString) ->
            ( model, Navigation.load urlString, Nothing )

        UrlChanged url ->
            session |> Router.route url |> Model.wrapPage |> (\( m, c ) -> ( m, c, Nothing ))

        Page pageMsg ->
            Page.update pageMsg session page |> Model.wrapPage |> (\( m, c ) -> ( m, c, Nothing ))

        Session sessionMsg ->
            let
                ( newSession, sessionEvent ) =
                    Session.update sessionMsg model.session
            in
            ( { model | session = newSession }, Cmd.none, sessionEvent )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    mainUpdate msg model
        |> runSessionCommands


runSessionCommands ( model, cmds, sessionEvent ) =
    let
        ( cleanSession, sessionCmds ) =
            Session.popCmd model.session

        newModel =
            { model | session = cleanSession }

        newCmds =
            Cmd.batch [ cmds, Cmd.map Msg.Session sessionCmds ]
    in
    sessionEvent
        |> Maybe.andThen (\event -> Page.wrapSessionEvent event model.page)
        |> Maybe.map
            (\m ->
                let
                    ( recModel, recCmds ) =
                        update (Msg.Page m) newModel
                in
                ( recModel, Cmd.batch [ newCmds, recCmds ] )
            )
        |> Maybe.withDefault ( newModel, newCmds )


subscriptions : Model -> Sub Msg
subscriptions model =
    Page.subscriptions model.session model.page |> Sub.map Msg.Page


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
    UrlRequested request


onUrlChange : Url -> Msg
onUrlChange url =
    UrlChanged url

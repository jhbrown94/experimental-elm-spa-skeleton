-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation
import Descriptors exposing (landingDescriptor)
import Html
import Model exposing (Model, wrapPage)
import Msg exposing (..)
import Page as Page
import Page.Landing as Landing
import Route exposing (Destination(..), NavState)
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


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        nav =
            { key = key, url = url }

        session : Session
        session =
            { nav = nav, authToken = Nothing }

        ( initialModel, _ ) =
            session
                |> Landing.init
                |> Page.init landingDescriptor
                |> wrapPage nav
    in
    Router.route url initialModel


view : Model -> Document Msg
view { session, page } =
    let
        { title, body } =
            Page.view session page
    in
    { title = title, body = body |> List.map (Html.map Page) }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ session, page } as model) =
    case msg of
        NoEvent ->
            ( model, Cmd.none )

        UrlRequested (Internal url) ->
            ( model, Navigation.pushUrl session.nav.key (Url.toString url) )

        UrlRequested (External urlString) ->
            ( model, Navigation.load urlString )

        UrlChanged url ->
            Router.route url model

        Page pageMsg ->
            Page.update pageMsg session page |> wrapPage session


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
    UrlRequested request


onUrlChange : Url -> Msg
onUrlChange url =
    UrlChanged url

-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Router exposing (onUrlChange, pushRoute)

import Browser.Navigation as Navigation
import Model exposing (Model)
import Msg exposing (Msg)
import Page exposing (Page)
import Page.About
import Page.Landing
import Page.Login
import Page.Logout
import Page.NotFound
import Page.Primary
import Page.Secondary
import Route exposing (..)
import Session exposing (Session)
import Url exposing (Url)


handlerFor url route model =
    case ( route, Model.session model ) of
        -- Special routing case: "/" goes to Landing or Primary depending on Session state
        ( Root, Just s ) ->
            Normal <| Page.Primary.init s

        ( Root, Nothing ) ->
            Normal <| Page.Landing.init

        ( Login success, s ) ->
            Normal <| Page.Login.init s success model

        ( Logout, _ ) ->
            Normal <| Page.Logout.init

        ( NotFound urlString, s ) ->
            Normal <| Page.NotFound.init s urlString

        -- Normal session required pages
        ( Secondary, Just s ) ->
            Normal <| Page.Secondary.init s

        -- Normal session-not-required pages
        ( About, s ) ->
            Normal <| Page.About.init s

        -- Catch-all to redirect session-required pages to Login if no session is present
        ( _, Nothing ) ->
            Redirect <| Login (Just url)


onUrlChange : Url -> Model -> ( Model, Cmd Msg )
onUrlChange url model =
    let
        nominalRoute =
            urlToRoute url

        handler =
            handlerFor url nominalRoute model
    in
    case handler of
        Normal ( page, cmd ) ->
            ( Model.setPage url page model, cmd )

        Redirect route ->
            ( model, Navigation.replaceUrl model.key (routeToUrlString route) )


pushRoute : Route -> Model -> ( Model, Cmd msg )
pushRoute route model =
    ( model, Navigation.pushUrl model.key (routeToUrlString route) )


type Handler
    = Normal ( Page Session Msg Model, Cmd Msg )
    | Redirect Route

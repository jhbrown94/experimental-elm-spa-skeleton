-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Router exposing (route)

import Descriptors exposing (..)
import Model exposing (Model, wrapPage)
import Msg exposing (Msg)
import Page
import Page.About as About
import Page.Landing as Landing
import Page.Login as Login
import Page.Logout as Logout
import Page.NotFound as NotFound
import Page.Primary as Primary
import Page.Secondary as Secondary
import PageMsg exposing (..)
import Route exposing (..)
import Url exposing (Url)


setNav newValue record =
    { record | nav = newValue }


setUrl newValue record =
    { record | url = newValue }


route : Url -> Model -> ( Model, Cmd Msg )
route url ({ session, page } as model) =
    let
        nominalDestination =
            Route.parseUrl url

        newSession =
            session |> setNav (session.nav |> setUrl url)

        newPage descriptor generator =
            newSession
                |> generator
                |> Page.init descriptor
                |> wrapPage newSession

        byDestination destination =
            case ( destination, session.authToken ) of
                ( Root, Nothing ) ->
                    newPage landingDescriptor Landing.init

                ( Root, Just _ ) ->
                    newPage primaryDescriptor Primary.init

                ( About, _ ) ->
                    newPage aboutDescriptor About.init

                ( NotFound _, _ ) ->
                    newPage notFoundDescriptor (NotFound.init (Url.toString url))

                ( Logout, _ ) ->
                    newPage logoutDescriptor Logout.init

                ( Secondary, Just _ ) ->
                    newPage secondaryDescriptor Secondary.init

                ( Login successUrl, Nothing ) ->
                    newPage loginDescriptor <| Login.init successUrl

                ( Login Nothing, Just _ ) ->
                    newPage primaryDescriptor Primary.init

                ( Login (Just urlString), Just _ ) ->
                    case urlString |> Url.fromString of
                        Just successUrl ->
                            route successUrl model

                        Nothing ->
                            newPage primaryDescriptor Primary.init

                -- Catch-all to redirect session-required pages to Login if no session is present
                ( _, Nothing ) ->
                    newPage loginDescriptor <| Login.init (Just (Url.toString url))
    in
    byDestination nominalDestination

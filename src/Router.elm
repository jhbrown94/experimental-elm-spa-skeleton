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
import Session exposing (Session)
import Url exposing (Url)


route : Url -> Session -> ( Session, Page.Model PageMsg, Cmd PageMsg )
route url session =
    let
        nominalDestination =
            Route.parseUrl url

        newSession =
            session |> Session.setUrl url

        byDestination destination =
            case ( destination, newSession |> Session.getAuthToken ) of
                ( Root, Nothing ) ->
                    newSession
                        |> Landing.init
                        |> Page.init landingDescriptor

                ( Root, Just _ ) ->
                    newSession |> Primary.init |> Page.init primaryDescriptor

                ( About, _ ) ->
                    newSession |> About.init |> Page.init aboutDescriptor

                ( NotFound _, _ ) ->
                    newSession |> NotFound.init (Url.toString url) |> Page.init notFoundDescriptor

                ( Logout, _ ) ->
                    newSession |> Logout.init |> Page.init logoutDescriptor

                ( Secondary, Just _ ) ->
                    newSession |> Secondary.init |> Page.init secondaryDescriptor

                ( Login successUrl, Nothing ) ->
                    newSession |> Login.init successUrl |> Page.init loginDescriptor

                ( Login Nothing, Just _ ) ->
                    newSession |> Primary.init |> Page.init primaryDescriptor

                ( Login (Just urlString), Just _ ) ->
                    case urlString |> Url.fromString of
                        Just successUrl ->
                            route successUrl newSession

                        Nothing ->
                            newSession |> Primary.init |> Page.init primaryDescriptor

                -- Catch-all to redirect session-required pages to Login if no session is present
                ( _, Nothing ) ->
                    newSession |> Login.init (Just (Url.toString url)) |> Page.init loginDescriptor
    in
    byDestination nominalDestination

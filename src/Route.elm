-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Route exposing (Route(..), routeToUrlString, urlStringToRoute, urlToRoute)

import Url exposing (Url)
import Url.Builder as Builder exposing (absolute)
import Url.Parser exposing (..)
import Url.Parser.Query as Query



-- Extend Route, routeParser, and routeToUrlString for additional routes


type Route
    = Root
    | NotFound String
    | Login (Maybe Url)
    | Logout
    | Secondary
    | About


routeParser =
    oneOf
        [ map Root top
        , map loginParserHelper (s loginSegment <?> Query.string loginSuccessKey)
        , map Logout (s logoutSegment)
        , map Secondary (s secondarySegment)
        , map About (s aboutSegment)

        -- NotFound is deliberately omitted
        ]


routeToUrlString : Route -> String
routeToUrlString route =
    case route of
        Root ->
            absolute [] []

        Login (Just successUrl) ->
            absolute [ loginSegment ] [ Builder.string loginSuccessKey (Url.toString successUrl) ]

        Login Nothing ->
            absolute [ loginSegment ] []

        Logout ->
            absolute [ logoutSegment ] []

        Secondary ->
            absolute [ secondarySegment ] []

        About ->
            absolute [ aboutSegment ] []

        NotFound failedUrl ->
            absolute [ notFoundSegment ] [ Builder.string notFoundKey failedUrl ]



-- Helper functions


loginParserHelper maybeUrl =
    case maybeUrl of
        Nothing ->
            Login Nothing

        Just urlString ->
            case Url.fromString urlString of
                Just url ->
                    Login <| Just url

                Nothing ->
                    NotFound urlString



-- Add constants here if you're as fussy as me, otherwise inline them above


loginSuccessKey =
    "success"


loginSegment =
    "login"


logoutSegment =
    "logout"


notFoundSegment =
    "notfound"


notFoundKey =
    "failed"


secondarySegment =
    "secondary"


aboutSegment =
    "about"



-- Machinery you can ignore


urlStringToRoute : String -> Route
urlStringToRoute urlString =
    urlString |> Url.fromString |> Maybe.map urlToRoute |> Maybe.withDefault (NotFound urlString)


urlToRoute : Url -> Route
urlToRoute url =
    url |> parse routeParser |> Maybe.withDefault (NotFound <| Url.toString url)

-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation
import Model exposing (Model)
import Msg exposing (MainMsg(..), Msg(..))
import Page exposing (Page)
import Page.Landing
import Page.Login
import Route
import Router
import Url exposing (Url)


type alias Flags =
    ()


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    Model.new
        { key = key
        , url = url
        , page = Tuple.first Page.Landing.init
        }
        |> Router.onUrlChange url



-- Views


view : Model -> Document Msg
view model =
    { title = viewTitle model, body = [ Page.view (Model.page model) model ] }


viewTitle model =
    Page.title <| Model.page model



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Main mainMsg ->
            case mainMsg of
                NoEvent ->
                    ( model, Cmd.none )

                PushRoute route ->
                    Router.pushRoute route model

                Logout ->
                    Router.pushRoute Route.Logout model

                UrlRequested (Internal url) ->
                    ( model, Navigation.pushUrl model.key (Url.toString url) )

                UrlRequested (External urlString) ->
                    ( model, Navigation.load urlString )

                UrlChanged url ->
                    Router.onUrlChange url model

        _ ->
            Page.update (Model.page model) msg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


onUrlRequest : UrlRequest -> Msg
onUrlRequest request =
    Main <| Msg.UrlRequested request


onUrlChange : Url -> Msg
onUrlChange url =
    Main <| Msg.UrlChanged url


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }

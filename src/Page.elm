-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page exposing
    ( Descriptor
    , Model
    , init
    , subscriptions
    , update
    , view
    , wrapSessionEvent
    )

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Html
import Route
import Session exposing (Session)
import Url


type Model mainmsg
    = Model
        { view : Session -> Browser.Document mainmsg
        , update : mainmsg -> Session -> ( Session, Model mainmsg, Cmd mainmsg )
        , subscriptions : Session -> Sub mainmsg
        , wrapSessionEvent : Session.Event -> Maybe mainmsg
        }


view : Session -> Model mainmsg -> Browser.Document mainmsg
view session (Model model) =
    model.view session


update : mainmsg -> Session -> Model mainmsg -> ( Session, Model mainmsg, Cmd mainmsg )
update msg session (Model model) =
    model.update msg session


subscriptions : Session -> Model mainmsg -> Sub mainmsg
subscriptions session (Model model) =
    model.subscriptions session


type alias Descriptor mainmsg msg model =
    { view : Session -> model -> Document msg
    , update : msg -> Session -> model -> ( Session, model, Cmd msg )
    , subscriptions : Maybe (Session -> model -> Sub msg)
    , msgWrapper : msg -> mainmsg
    , msgFilter : mainmsg -> Maybe msg
    , wrapSessionEvent : Maybe (Session.Event -> msg)
    }


init : Descriptor mainmsg msg model -> ( Session, model, Cmd msg ) -> ( Session, Model mainmsg, Cmd mainmsg )
init descriptor ( session, pageModel, cmd ) =
    ( session
    , buildModel descriptor pageModel
    , Cmd.map descriptor.msgWrapper cmd
    )


wrapSessionEvent : Session.Event -> Model mainmsg -> Maybe mainmsg
wrapSessionEvent event (Model model) =
    event |> model.wrapSessionEvent


buildModel : Descriptor mainmsg msg model -> model -> Model mainmsg
buildModel descriptor newModel =
    let
        buildView : Session -> Document mainmsg
        buildView =
            \session ->
                let
                    { title, body } =
                        descriptor.view session newModel
                in
                { title = title, body = List.map (Html.map descriptor.msgWrapper) body }

        buildUpdate : mainmsg -> Session -> ( Session, Model mainmsg, Cmd mainmsg )
        buildUpdate =
            newUpdate descriptor newModel

        buildSubscriptions : Session -> Sub mainmsg
        buildSubscriptions =
            descriptor.subscriptions
                |> Maybe.map
                    (\subs ->
                        \session ->
                            subs session newModel |> Sub.map descriptor.msgWrapper
                    )
                |> Maybe.withDefault (\session -> Sub.none)

        buildWrapSessionEvent : Session.Event -> Maybe mainmsg
        buildWrapSessionEvent event =
            descriptor.wrapSessionEvent
                |> Maybe.map (\wrap -> event |> wrap |> descriptor.msgWrapper)
    in
    Model
        { view = buildView
        , update = buildUpdate
        , subscriptions = buildSubscriptions
        , wrapSessionEvent = buildWrapSessionEvent
        }


newUpdate : Descriptor mainmsg msg model -> model -> mainmsg -> Session -> ( Session, Model mainmsg, Cmd mainmsg )
newUpdate descriptor oldModel mainMsg oldSession =
    case descriptor.msgFilter mainMsg of
        Just msg ->
            let
                ( newSession, newModel, cmd ) =
                    descriptor.update msg oldSession oldModel
            in
            ( newSession, buildModel descriptor newModel, Cmd.map descriptor.msgWrapper cmd )

        Nothing ->
            ( oldSession, buildModel descriptor oldModel, Cmd.none )

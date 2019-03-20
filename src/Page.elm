-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page exposing (Descriptor, Model, init, update, view)

import Browser exposing (Document)
import Html


type Model mainmsg session
    = Model
        { view : session -> Browser.Document mainmsg
        , update : mainmsg -> session -> ( session, Model mainmsg session, Cmd mainmsg )
        }


view : session -> Model mainmsg session -> Browser.Document mainmsg
view session (Model model) =
    model.view session


update : mainmsg -> session -> Model mainmsg session -> ( session, Model mainmsg session, Cmd mainmsg )
update msg session (Model model) =
    model.update msg session


type alias Descriptor mainmsg msg model session =
    { view : session -> model -> Document msg
    , update : msg -> session -> model -> ( session, model, Cmd msg )
    , msgWrapper : msg -> mainmsg
    , msgFilter : mainmsg -> Maybe msg
    }


init : Descriptor mainmsg msg model session -> ( session, model, Cmd msg ) -> ( session, Model mainmsg session, Cmd mainmsg )
init descriptor ( session, pageModel, cmd ) =
    ( session
    , buildModel descriptor pageModel
    , Cmd.map descriptor.msgWrapper cmd
    )


buildModel : Descriptor mainmsg msg model session -> model -> Model mainmsg session
buildModel descriptor newModel =
    let
        buildView : session -> Document mainmsg
        buildView =
            \session ->
                let
                    { title, body } =
                        descriptor.view session newModel
                in
                { title = title, body = List.map (Html.map descriptor.msgWrapper) body }

        buildUpdate : mainmsg -> session -> ( session, Model mainmsg session, Cmd mainmsg )
        buildUpdate =
            newUpdate descriptor newModel
    in
    Model
        { view = buildView
        , update = buildUpdate
        }


newUpdate : Descriptor mainmsg msg model session -> model -> mainmsg -> session -> ( session, Model mainmsg session, Cmd mainmsg )
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

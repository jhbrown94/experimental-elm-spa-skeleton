-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Page exposing
    ( DataNoSession
    , DataWithOptionalSession
    , DataWithSession
    , Page
    , UpdateNoSession
    , UpdateWithOptionalSession
    , UpdateWithSession
    , ViewNoSession
    , ViewWithOptionalSession
    , ViewWithSession
    , session
    , title
    , update
    , updateNoSession
    , updateWithOptionalSession
    , updateWithSession
    , view
    , withNoSession
    , withOptionalSession
    , withSession
    )

import Html exposing (Html)



-- Page


type alias PageRep session msg model =
    { view : ViewFn msg model
    , update : UpdateFn msg model
    , title : String
    , session : Maybe session
    }


type Page session msg model
    = Page (PageRep session msg model)


type alias ViewFn msg model =
    model -> Html msg


type alias UpdateFn msg model =
    msg -> model -> ( model, Cmd msg )


view (Page rep) =
    rep.view


update (Page rep) =
    rep.update


title (Page rep) =
    rep.title


session (Page rep) =
    rep.session



-- Building pages


type WithSession session state msg model
    = WithSession (RepWithSession session state msg model)


type WithOptionalSession session state msg model
    = WithOptionalSession (RepWithOptionalSession session state msg model)


type WithNoSession state msg model
    = WithNoSession (RepNoSession state msg model)


type alias RepNoSession state msg model =
    { data : DataNoSession state
    , view : ViewNoSession state msg model
    , update : UpdateNoSession state msg model
    }


type alias RepWithSession session state msg model =
    { data : DataWithSession session state
    , view : ViewWithSession session state msg model
    , update : UpdateWithSession session state msg model
    }


type alias RepWithOptionalSession session state msg model =
    { data : DataWithOptionalSession session state
    , view : ViewWithOptionalSession session state msg model
    , update : UpdateWithOptionalSession session state msg model
    }


type alias DataNoSession state =
    { state : state
    , title : String
    }


type alias DataWithSession session state =
    { session : session
    , state : state
    , title : String
    }


type alias DataWithOptionalSession session state =
    DataWithSession (Maybe session) state


type alias ViewNoSession state msg model =
    DataNoSession state -> ViewFn msg model


type alias ViewWithSession session state msg model =
    DataWithSession session state -> ViewFn msg model


type alias ViewWithOptionalSession session state msg model =
    DataWithOptionalSession session state -> ViewFn msg model


type alias UpdateNoSession state msg model =
    WithNoSession state msg model -> DataNoSession state -> UpdateFn msg model


type alias UpdateWithSession session state msg model =
    WithSession session state msg model -> DataWithSession session state -> UpdateFn msg model


type alias UpdateWithOptionalSession session state msg model =
    WithOptionalSession session state msg model -> DataWithOptionalSession session state -> UpdateFn msg model


withNoSession :
    ViewNoSession state msg model
    -> UpdateNoSession state msg model
    -> DataNoSession state
    -> Page session msg model
withNoSession viewFn updateFn data =
    let
        builder =
            WithNoSession
                { data = data
                , view = viewFn
                , update = updateFn
                }
    in
    Page <|
        { session = Nothing
        , title = data.title
        , view = viewFn data
        , update = updateFn builder data
        }


withSession :
    ViewWithSession session state msg model
    -> UpdateWithSession session state msg model
    -> DataWithSession session state
    -> Page session msg model
withSession viewFn updateFn data =
    let
        builder =
            WithSession
                { data = data
                , view = viewFn
                , update = updateFn
                }
    in
    Page <|
        { view = viewFn data
        , update = updateFn builder data
        , title = data.title
        , session = Just data.session
        }


withOptionalSession :
    ViewWithOptionalSession session state msg model
    -> UpdateWithOptionalSession session state msg model
    -> DataWithOptionalSession session state
    -> Page session msg model
withOptionalSession viewFn updateFn data =
    let
        builder =
            WithOptionalSession
                { data = data
                , view = viewFn
                , update = updateFn
                }
    in
    Page <|
        { view = viewFn data
        , update = updateFn builder data
        , title = data.title
        , session = data.session
        }


updateNoSession nextData (WithNoSession oldRep) =
    withNoSession oldRep.view oldRep.update nextData


updateWithOptionalSession nextData (WithOptionalSession oldRep) =
    withOptionalSession oldRep.view oldRep.update nextData


updateWithSession nextData (WithSession oldRep) =
    withSession oldRep.view oldRep.update nextData

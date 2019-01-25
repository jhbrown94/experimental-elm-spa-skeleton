-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Model exposing (Model, new, page, session, setPage, updatePageInPlace)

import Browser.Navigation
import Msg exposing (Msg)
import Page exposing (Page)
import Session exposing (Session)
import Url
import Url.Builder


type alias Model =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , page : ModelPage
    }


new options =
    Model options.key options.url (ModelPage options.page)


type ModelPage
    = ModelPage (Page.Page Session Msg Model)


page model =
    let
        (ModelPage thePage) =
            model.page
    in
    thePage


session model =
    Page.session <| page model


setPage : Url.Url -> Page Session Msg Model -> Model -> Model
setPage url thePage model =
    { model | url = url, page = ModelPage thePage }


updatePageInPlace : Page.Page Session Msg Model -> Model -> Model
updatePageInPlace updatedPage model =
    { model | page = ModelPage updatedPage }

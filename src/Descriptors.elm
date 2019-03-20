-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Descriptors exposing
    ( aboutDescriptor
    , landingDescriptor
    , loginDescriptor
    , logoutDescriptor
    , notFoundDescriptor
    , primaryDescriptor
    , secondaryDescriptor
    )

import Page exposing (Descriptor)
import Page.About as About
import Page.Landing as Landing
import Page.Login as Login
import Page.Logout as Logout
import Page.NotFound as NotFound
import Page.Primary as Primary
import Page.Secondary as Secondary
import PageMsg exposing (PageMsg(..))
import Session exposing (Session)


loginDescriptor : Descriptor PageMsg Login.Msg Login.Model Session
loginDescriptor =
    { view = Login.view
    , update = Login.update
    , msgWrapper = LoginMsg
    , msgFilter =
        \main ->
            case main of
                LoginMsg msg ->
                    Just msg

                _ ->
                    Nothing
    }


logoutDescriptor : Descriptor PageMsg Logout.Msg Logout.Model Session
logoutDescriptor =
    { view = Logout.view
    , update = Logout.update
    , msgWrapper = LogoutMsg
    , msgFilter =
        \main ->
            case main of
                LogoutMsg msg ->
                    Just msg

                _ ->
                    Nothing
    }


primaryDescriptor : Descriptor PageMsg Primary.Msg Primary.Model Session
primaryDescriptor =
    { view = Primary.view
    , update = Primary.update
    , msgWrapper = PrimaryMsg
    , msgFilter =
        \main ->
            case main of
                PrimaryMsg msg ->
                    Just msg

                _ ->
                    Nothing
    }


secondaryDescriptor : Descriptor PageMsg Secondary.Msg Secondary.Model Session
secondaryDescriptor =
    { view = Secondary.view
    , update = Secondary.update
    , msgWrapper = SecondaryMsg
    , msgFilter =
        \main ->
            case main of
                SecondaryMsg msg ->
                    Just msg

                _ ->
                    Nothing
    }


notFoundDescriptor : Descriptor PageMsg NotFound.Msg NotFound.Model Session
notFoundDescriptor =
    { view = NotFound.view
    , update = NotFound.update
    , msgWrapper = NotFoundMsg
    , msgFilter =
        \main ->
            case main of
                NotFoundMsg msg ->
                    Just msg

                _ ->
                    Nothing
    }


aboutDescriptor : Descriptor PageMsg About.Msg About.Model Session
aboutDescriptor =
    { view = About.view
    , update = About.update
    , msgWrapper = AboutMsg
    , msgFilter =
        \main ->
            case main of
                AboutMsg msg ->
                    Just msg

                _ ->
                    Nothing
    }


landingDescriptor : Descriptor PageMsg Landing.Msg Landing.Model Session
landingDescriptor =
    { view = Landing.view
    , update = Landing.update
    , msgWrapper = LandingMsg
    , msgFilter =
        \main ->
            case main of
                LandingMsg msg ->
                    Just msg

                _ ->
                    Nothing
    }

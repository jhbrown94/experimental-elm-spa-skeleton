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

import Browser exposing (Document)
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


loginDescriptor : Descriptor PageMsg Login.Msg Login.Model
loginDescriptor =
    { view = Login.view
    , update = Login.update
    , subscriptions = Nothing
    , wrapSessionEvent = Nothing
    , msgWrapper = LoginMsg
    , msgFilter =
        \main ->
            case main of
                LoginMsg msg ->
                    Just msg

                _ ->
                    Nothing
    }


logoutDescriptor : Descriptor PageMsg Logout.Msg Logout.Model
logoutDescriptor =
    { view = Logout.view
    , update = Logout.update
    , subscriptions = Nothing
    , msgWrapper = LogoutMsg
    , msgFilter =
        \main ->
            case main of
                LogoutMsg msg ->
                    Just msg

                _ ->
                    Nothing
    , wrapSessionEvent = Nothing
    }


primaryDescriptor : Descriptor PageMsg Primary.Msg Primary.Model
primaryDescriptor =
    { view = Primary.view
    , update = Primary.update
    , subscriptions = Nothing
    , msgWrapper = PrimaryMsg
    , msgFilter =
        \main ->
            case main of
                PrimaryMsg msg ->
                    Just msg

                _ ->
                    Nothing
    , wrapSessionEvent = Nothing
    }


secondaryDescriptor : Descriptor PageMsg Secondary.Msg Secondary.Model
secondaryDescriptor =
    { view = Secondary.view
    , update = Secondary.update
    , subscriptions = Nothing
    , msgWrapper = SecondaryMsg
    , msgFilter =
        \main ->
            case main of
                SecondaryMsg msg ->
                    Just msg

                _ ->
                    Nothing
    , wrapSessionEvent = Nothing
    }


notFoundDescriptor : Descriptor PageMsg NotFound.Msg NotFound.Model
notFoundDescriptor =
    { view = NotFound.view
    , update = NotFound.update
    , subscriptions = Nothing
    , msgWrapper = NotFoundMsg
    , msgFilter =
        \main ->
            case main of
                NotFoundMsg msg ->
                    Just msg

                _ ->
                    Nothing
    , wrapSessionEvent = Nothing
    }


aboutDescriptor : Descriptor PageMsg About.Msg About.Model
aboutDescriptor =
    { view = About.view
    , update = About.update
    , subscriptions = Nothing
    , msgWrapper = AboutMsg
    , msgFilter =
        \main ->
            case main of
                AboutMsg msg ->
                    Just msg

                _ ->
                    Nothing
    , wrapSessionEvent = Nothing
    }


landingDescriptor : Descriptor PageMsg Landing.Msg Landing.Model
landingDescriptor =
    { view = Landing.view
    , update = Landing.update
    , subscriptions = Nothing
    , msgWrapper = LandingMsg
    , msgFilter =
        \main ->
            case main of
                LandingMsg msg ->
                    Just msg

                _ ->
                    Nothing
    , wrapSessionEvent = Nothing
    }

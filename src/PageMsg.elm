-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module PageMsg exposing (PageMsg(..))

import Page.About as About
import Page.Landing as Landing
import Page.Login as Login
import Page.Logout as Logout
import Page.NotFound as NotFound
import Page.Primary as Primary
import Page.Secondary as Secondary


type PageMsg
    = AboutMsg About.Msg
    | LandingMsg Landing.Msg
    | LoginMsg Login.Msg
    | LogoutMsg Logout.Msg
    | NotFoundMsg NotFound.Msg
    | PrimaryMsg Primary.Msg
    | SecondaryMsg Secondary.Msg

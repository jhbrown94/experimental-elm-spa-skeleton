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

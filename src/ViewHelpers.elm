-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module ViewHelpers exposing (aboutButton, appName, black, button, buttonRounded, dialogPage, gray, logoutButton, pageTitle, white, window, windowRounded)

import Element
    exposing
        ( Element
        , alignRight
        , centerX
        , centerY
        , column
        , el
        , fill
        , padding
        , rgb255
        , row
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Model
import Msg
import Route


appName =
    "SPAdemo"


pageTitle pageName =
    appName ++ ": " ++ pageName


dialogPage rest =
    Element.layout [] <|
        window [ centerX, centerY ]
            (column
                [ spacing 10 ]
                [ el [ centerX ] (text appName)
                , el [] rest
                ]
            )


aboutButton =
    button [] { onPress = Just <| Msg.Main <| Msg.PushRoute Route.About, label = text "About" }


logoutButton model =
    if Model.session model == Nothing then
        Element.none

    else
        button [] { onPress = Just <| Msg.Main <| Msg.Logout, label = text "Log out" }


window attributes =
    el
        ([ Background.color black
         , Font.color white
         , Border.rounded windowRounded
         , padding 30
         ]
            ++ attributes
        )


button attributes =
    Input.button
        ([ Border.rounded buttonRounded
         , padding 5
         , Border.color white
         , Border.width 2
         ]
            ++ attributes
        )


windowRounded =
    10


buttonRounded =
    10


black =
    rgb255 0 0 0


gray =
    rgb255 128 128 128


white =
    rgb255 255 255 255

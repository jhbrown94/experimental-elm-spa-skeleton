-- Copyright 2019 Jeremy H. Brown
--
-- The copyright holder licenses this file to you under the MIT License (the
-- "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at https://opensource.org/licenses/MIT


module Session exposing (Session)

import Json.Decode exposing (Value)
import Route exposing (NavState)


type alias Session =
    { nav : NavState
    , authToken : Maybe String
    }

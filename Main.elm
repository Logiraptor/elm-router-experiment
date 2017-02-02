module Main exposing (..)

import Router
import ProgA
import ProgB
import ProgC
import Navigation


main =
    Router.default ProgA.prog
        |> Router.route ( "/b", ProgB.prog )
        |> Router.route ( "/c", ProgC.prog )
        |> Navigation.program Router.SetLocation

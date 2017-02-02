module ProgB exposing (..)

import Html
import Html.Events as Events
import Router
import Navigation


{-
   In order to keep this program simple, all it can do is navigate.
   Therefore, the message type is String, and the model type is ().
   The message is just the new path to navigate to.
-}


prog : Router.NoFlagProgram () String
prog =
    { init = ( (), Cmd.none )
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }


view : () -> Html.Html String
view _ =
    Html.span []
        [ Html.text "You're on page B. Click the link to go to another page:"
        , Html.br [] []
        , Html.a [ Events.onClick "/a" ] [ Html.text "a" ]
        , Html.br [] []
        , Html.a [ Events.onClick "/b" ] [ Html.text "b" ]
        , Html.br [] []
        , Html.a [ Events.onClick "/c" ] [ Html.text "c" ]
        ]


update : String -> () -> ( (), Cmd String )
update url _ =
    ( (), Navigation.newUrl url )

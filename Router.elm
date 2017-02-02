module Router exposing (..)

import Navigation
import Html
import Tuple


type alias NoFlagProgram model msg =
    { init : ( model, Cmd msg )
    , view : model -> Html.Html msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    }


type alias FullProgram flags model msg =
    { init : flags -> ( model, Cmd msg )
    , view : model -> Html.Html msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    }


type alias Init flags model msg =
    flags -> ( model, Cmd msg )


type alias View model msg =
    model -> Html.Html msg


type alias Update msg model =
    msg -> model -> ( model, Cmd msg )


type alias Subs model msg =
    model -> Sub msg


type alias Prog model msg =
    FullProgram Navigation.Location (WithLoc model) (SetLocation msg)


type SetLocation a b
    = SetLocation Navigation.Location
    | HeadMsg a
    | TailMsg b


type WithLoc a b
    = WithLoc Navigation.Location a b


default : NoFlagProgram a b -> FullProgram Navigation.Location a (SetLocation b ())
default { init, view, update, subscriptions } =
    { init = (\_ -> init |> Tuple.mapSecond (Cmd.map HeadMsg))
    , view = view >> Html.map HeadMsg
    , update = liftUpdate update
    , subscriptions = subscriptions >> Sub.map HeadMsg
    }


liftUpdate : Update a b -> Update (SetLocation a ()) b
liftUpdate update msg model =
    case msg of
        HeadMsg msg ->
            let
                ( m, c ) =
                    update msg model
            in
                ( m, Cmd.map HeadMsg c )

        _ ->
            ( model, Cmd.none )


route : ( String, NoFlagProgram a b ) -> FullProgram Navigation.Location c (SetLocation d e) -> FullProgram Navigation.Location (WithLoc a c) (SetLocation b (SetLocation d e))
route ( path, handler ) rest =
    { init = init handler.init rest.init
    , view = view path handler.view rest.view
    , update = update handler.update rest.update
    , subscriptions = subscriptions handler.subscriptions rest.subscriptions
    }


init : ( a, Cmd b ) -> Init Navigation.Location c d -> Init Navigation.Location (WithLoc a c) (SetLocation b d)
init ainit binit flags =
    let
        ( aValue, acmd ) =
            ainit

        ( bValue, bcmd ) =
            binit flags
    in
        ( WithLoc flags aValue bValue, Cmd.batch [ Cmd.map HeadMsg acmd, Cmd.map TailMsg bcmd ] )


view : String -> View a b -> View c d -> View (WithLoc a c) (SetLocation b d)
view path aview bview (WithLoc l head tail) =
    case path == l.pathname of
        True ->
            Html.map HeadMsg (aview head)

        False ->
            Html.map TailMsg (bview tail)


update : Update a b -> Update (SetLocation c e) d -> Update (SetLocation a (SetLocation c e)) (WithLoc b d)
update aupdate bupdate msg (WithLoc loc head tail) =
    case msg of
        HeadMsg msg ->
            let
                ( newHead, cmd ) =
                    aupdate msg head
            in
                ( WithLoc loc newHead tail, Cmd.map HeadMsg cmd )

        TailMsg msg ->
            let
                ( newTail, cmd ) =
                    bupdate msg tail
            in
                ( WithLoc loc head newTail, Cmd.map TailMsg cmd )

        SetLocation newLoc ->
            let
                ( newTail, cmd ) =
                    bupdate (SetLocation newLoc) tail
            in
                ( WithLoc newLoc head newTail, Cmd.map TailMsg cmd )


subscriptions : Subs a b -> Subs c d -> Subs (WithLoc a c) (SetLocation b d)
subscriptions asubs bsubs (WithLoc _ head tail) =
    Sub.batch [ Sub.map HeadMsg (asubs head), Sub.map TailMsg (bsubs tail) ]

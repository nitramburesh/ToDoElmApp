module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)
import RemoteData exposing (RemoteData(..))
import Http
import Json.Decode exposing (Decoder, int, string, bool)
import Json.Decode.Pipeline exposing (required)


---- MODEL ----


type Model 
    = NotAsked
    | Loading
    | Failure
    | Success String

type alias ToDoItem =
    {
    userId: Int,
    id: Int,
    title: String,
    completed: Bool
    }

itemDecoder : Decoder ToDoItem
itemDecoder =
    Json.Decode.succeed ToDoItem    
        |> required "userId" int
        |> required "id" int
        |> required "title" string
        |> required "completed" bool

getToDoItems : Cmd Msg
getToDoItems = 
    Http.get 
        { url = "https://jsonplaceholder.typicode.com/todos"
        , expect = Http.expectJson GotItems itemDecoder
        }
log = Debug.log getToDoItems

init : ( Model, Cmd Msg )
init =
    (Model, Cmd.none)



---- UPDATE ----


type Msg
    = GotItems (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/checklist-logo.png" ] []
        , h1 [] [ text "Welcome to my TODO app" ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }

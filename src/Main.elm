module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)
import Http
import Json.Decode exposing (Decoder, string, int, bool, list)
import Json.Decode.Pipeline exposing (required)
import RemoteData
import Debug exposing (toString)
import Html exposing (button)
import Html.Events exposing (onClick)
import Html.Events exposing (on)
---- MODEL ----


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
        , expect = Http.expectJson (RemoteData.fromResult >> GotItems) (list itemDecoder)
        }

type alias Model =
    {
        toDoItems : RemoteData.WebData (List ToDoItem)
    }
        
type alias ToDoResponse = 
    RemoteData.WebData (List ToDoItem)

init : ( Model, Cmd Msg )
init = ({ toDoItems = RemoteData.NotAsked}
    , Cmd.none)
    



---- UPDATE ----


type Msg
    = GotItems ToDoResponse
    | ClickedFetchTodos


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of
    ClickedFetchTodos -> 
        ({model | toDoItems = RemoteData.Loading}
        , getToDoItems
        )
    GotItems response ->
        ( {model | toDoItems = response}
        , Cmd.none
        )
---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/checklist-logo.png" ] []
        , h1 [] [ text "Welcome to my TODO app" ]
        , button [onClick ClickedFetchTodos] [text "SHOW TO DO LIST"]
        , viewItems model.toDoItems
        ]

viewItems : ToDoResponse -> Html msg 
viewItems model = 
    case model of
            RemoteData.NotAsked -> div [][ text ""]
            RemoteData.Loading -> div [][ text "loading list..."]
            RemoteData.Failure _ -> div [][ text "failed to load"]
            RemoteData.Success toDoItems ->     
                div [] (List.map viewFinalItems toDoItems)
viewFinalItems : ToDoItem -> Html msg
viewFinalItems toDoItem = 
    let
        toDoItemFormated = 
            toDoItemFormat toDoItem
    in
        div[][text toDoItemFormated]

toDoItemFormat : ToDoItem -> String
    
toDoItemFormat toDoItem =
            String.fromInt toDoItem.id ++ " " ++ toDoItem.title
 
---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }

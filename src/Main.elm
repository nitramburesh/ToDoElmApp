module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)
import Http
import Json.Decode exposing (Decoder, string, int, bool)
import Json.Decode.Pipeline exposing (required)
import RemoteData
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
        , expect = Http.expectJson (RemoteData.fromResult >> GotItems) itemDecoder
        }

type alias Model =
    {
        toDoItem : RemoteData.WebData ToDoItem
    }
        


init : ( Model, Cmd Msg )
init =
    ({toDoItem = RemoteData.Loading},getToDoItems)



---- UPDATE ----


type Msg
    = GotItems (RemoteData.WebData ToDoItem)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of
      GotItems response ->
        ( {model | toDoItem = response}
        , Cmd.none
        )
---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/checklist-logo.png" ] []
        , h1 [] [ text "Welcome to my TODO app" ]
        ]

viewItems : Model -> ToDoItem -> Html msg 
viewItems model = 
    case model.toDoItem of
            RemoteData.NotAsked -> div [][ text "initializing"]
            RemoteData.Loading -> div [][ text "loading"]
            RemoteData.Failure toDoItem -> div [][ text "failed to load"]
            RemoteData.Success toDoItem -> div [][text model.toDoItem]

    
---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }

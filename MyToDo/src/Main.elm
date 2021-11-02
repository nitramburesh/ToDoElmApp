module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h1, img, text)
import Html.Attributes exposing (src)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, bool, int, string)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)



---- MODEL ----


type alias ToDoItem =
    { id : Int
    , title : String
    }


type alias Model =
    { toDoItems : WebData (List ToDoItem)
    }


type RemoteData
    = NotAsked
    | Loading
    | Failure
    | Success (List ToDoItem)


decodeToDoItems : Decoder ToDoItem
decodeToDoItems =
    Json.Decode.succeed ToDoItem
        |> required "id" int
        |> required "title" string


init : ( Model, Cmd Msg )
init =
    ( { toDoItems = RemoteData.NotAsked }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = FetchResponse (WebData (List ToDoItem))
    | FetchToDos


getToDoItems : Cmd Msg
getToDoItems =
    Http.get
        { url = "https://jsonplaceholder.typicode.com/todos"
        , expect = Http.expectJson (RemoteData.fromResult >> FetchResponse) (Json.Decode.list decodeToDoItems)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchResponse response ->
            ( { model | toDoItems = response }
            , Cmd.none
            )

        FetchToDos ->
            ( model
            , getToDoItems
            )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.png" ] []
        , h1 [] [ text "Heyo, what's up!" ]
        , button [ onClick FetchToDos ] [ text "fetch me items" ]
        , viewToDos model
        ]


viewToDos : Model -> Html msg
viewToDos model =
    case model.toDoItems of
        RemoteData.NotAsked ->
            div [] [ text "not asked yet" ]

        RemoteData.Loading ->
            div [] [ text "loading items..." ]

        RemoteData.Failure _ ->
            div [] [ text "loading items failed." ]

        RemoteData.Success toDoItems ->
            div [] (viewToDoList toDoItems)


viewToDoList : List ToDoItem -> List (Html msg)
viewToDoList toDoItems =
    let
        formattedItems =
            formatItems toDoItems

        mappedItems =
            List.map (\item -> div [] [ text item ]) formattedItems
    in
    mappedItems


formatItems : List ToDoItem -> List String
formatItems toDoItems =
    List.map (\item -> String.fromInt item.id ++ " - " ++ item.title) toDoItems



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }

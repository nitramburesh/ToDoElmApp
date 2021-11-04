module Main exposing (..)

import Browser
import Html
import Html.Styled exposing (Html, button, div, h1, img, input, text)
import Html.Styled.Attributes exposing (src, type_)
import Html.Styled.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, bool, int, string)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)
import Styled exposing (btn, itemWrapper, itemDiv, wrapper, styledh1, textDiv, fetchMsg, styledCheckBox)



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
        , styledh1 [] [ text "Welcome to my TODO APP!" ]
        , btn [ onClick FetchToDos ] [ text "show to do list" ]
        , wrapper []
            [ itemWrapper [] [ viewToDos model ]
            ]
        ]


viewToDos : Model -> Html msg
viewToDos model =
    case model.toDoItems of
        RemoteData.NotAsked ->
            fetchMsg [] [ text "press the button to view to do list" ]

        RemoteData.Loading ->
            fetchMsg [] [ text "loading items..." ]

        RemoteData.Failure _ ->
            fetchMsg [] [ text "loading items failed." ]

        RemoteData.Success toDoItems ->
            div [] (viewToDoList toDoItems)


viewToDoList : List ToDoItem -> List (Html msg)
viewToDoList toDoItems =
    let
        formattedItems =
            formatItems toDoItems

        mappedItems =
            List.map
                (\item ->
                    itemDiv []
                        [ styledCheckBox [ type_ "checkbox" ] [], textDiv [] [ text item ] ]
                )
                formattedItems
    in
    mappedItems


formatItems : List ToDoItem -> List String
formatItems toDoItems =
    List.map (\item -> item.title) toDoItems



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view >> Html.Styled.toUnstyled
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }

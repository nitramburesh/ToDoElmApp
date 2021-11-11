module Main exposing (..)

import Browser
import Html.Styled as HtmlStyled exposing (Html, div, img, input, text)
import Html.Styled.Attributes as Attributes
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import RemoteData
import Styled exposing (btn, itemDiv, itemWrapper, styledText, styledh1, textDiv, wrapper)



{--- TODO:
FIX IMPORTS!
FETCH ON INIT AND TOGGLE HIDE/SHOW STATE
API URL - send "/todos" only
ENCODE URL 
FILTER FETCHED ITEMS
OPAQUE TYPES - API MODULE
MORE PAGES
ROUTING
SHARED STATE (TACO)
ENV VARIABLES
SET STATE TO LOCAL STORAGE

---}
---- MODEL ----


type alias Config =
    { base_url : String
    }


type alias ToDoItem =
    { id : Int
    , title : String
    }


type alias Model =
    { toDoItems : RemoteData.WebData (List ToDoItem)
    , showingItems : Bool
    , config : Config
    }


decodeToDoItems : Decode.Decoder ToDoItem
decodeToDoItems =
    Decode.succeed ToDoItem
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "title" Decode.string


init : Config -> ( Model, Cmd Msg )
init config =
    ( { toDoItems = RemoteData.Loading
      , showingItems = False
      , config = config
      }
    , Http.get
        { url = config.base_url ++ "todos"
        , expect = Http.expectJson (\response -> response |> RemoteData.fromResult |> FetchResponse) (Decode.list decodeToDoItems)
        }
    )


buttonTitle : Model -> String
buttonTitle { showingItems } =
    if showingItems == False then
        "Show list"

    else
        "hide list"



---- UPDATE ----


type Msg
    = FetchResponse (RemoteData.WebData (List ToDoItem))
    | ToggledToDoList


toggleToDoList : Model -> Model
toggleToDoList model =
    if model.showingItems == True then
        { model | showingItems = False }

    else
        { model | showingItems = True }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchResponse response ->
            ( { model | toDoItems = response }
            , Cmd.none
            )

        ToggledToDoList ->
            ( toggleToDoList model
            , Cmd.none
            )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ Attributes.src "/logo.png" ] []
        , styledh1 [ text "welcome to: to do app 3000!" ]
        , btn ToggledToDoList [ text (buttonTitle model) ]
        , wrapper
            [ itemWrapper [ viewToDos model ]
            ]
        ]


viewToDos : Model -> Html msg
viewToDos { toDoItems, showingItems } =
    case toDoItems of
        RemoteData.NotAsked ->
            styledText [ text "press the button to view to do list" ]

        RemoteData.Loading ->
            styledText [ text "loading items..." ]

        RemoteData.Failure _ ->
            styledText [ text "loading items failed..." ]

        RemoteData.Success items ->
            if showingItems == True then
                div [] (viewToDoList items)

            else
                styledText [ text "click button to show the list" ]


viewToDoList : List ToDoItem -> List (Html msg)
viewToDoList toDoItems =
    let
        formattedItems =
            formatItems toDoItems

        mappedItems =
            List.map
                (\item ->
                    itemDiv
                        [ input [ Attributes.type_ "checkbox" ] []
                        , textDiv [ text item ]
                        ]
                )
                formattedItems
    in
    mappedItems


formatItems : List ToDoItem -> List String
formatItems =
    List.map (\item -> item.title)



---- PROGRAM ----


main : Program Config Model Msg
main =
    Browser.element
        { view = view >> HtmlStyled.toUnstyled
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }

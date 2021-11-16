port module Main exposing (..)

import Browser
import Html
import Html.Attributes exposing (id, placeholder)
import Html.Events
import Html.Styled as HtmlStyled exposing (Html, div, img, input, text)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as HtmlEvents exposing (onInput)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import RemoteData
import Styled exposing (btn, itemDiv, itemWrapper, styledText, styledh1, textDiv, wrapper)
import Styled exposing (styledInput)



-- import Html.Styled.Attributes exposing (placeholder)
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
---- PORTS ----


port storeItems : Encode.Value -> Cmd msg



---- MODEL ----


type alias Config =
    { base_url : String
    }


type alias ToDoItem =
    { id : Int
    , title : String
    , completed : Bool
    }


type alias Model =
    { initToDoItems : RemoteData.WebData (List ToDoItem)
    , showingItems : Bool
    , searchedText : String
    , config : Config
    }



--- SUBSCRIPTIONS ---
---- UPDATE ----


type Msg
    = FetchResponse (RemoteData.WebData (List ToDoItem))
    | ToggledToDoList
    | ClickedCheckbox Int (List ToDoItem)
    | TextInput String


decodeToDoItems : Decode.Decoder ToDoItem
decodeToDoItems =
    Decode.succeed ToDoItem
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "completed" Decode.bool


encodeToDoItems : ToDoItem -> Encode.Value
encodeToDoItems item =
    Encode.object
        [ ( "id", Encode.int item.id )
        , ( "title", Encode.string item.title )
        , ( "completed", Encode.bool item.completed )
        ]


init : Config -> ( Model, Cmd Msg )
init config =
    ( { initToDoItems = RemoteData.Loading
      , showingItems = False
      , config = config
      , searchedText = ""
      }
    , Http.get
        { url = config.base_url ++ "/todos"
        , expect = Http.expectJson (\response -> response |> RemoteData.fromResult |> FetchResponse) (Decode.list decodeToDoItems)
        }
    )


buttonTitle : Model -> String
buttonTitle { showingItems } =
    if showingItems == False then
        "Show list"

    else
        "hide list"


toggleToDoList : Model -> Model
toggleToDoList model =
    if model.showingItems == True then
        { model | showingItems = False }

    else
        { model | showingItems = True }


clickedCheckbox : Model -> Int -> List ToDoItem -> ( Model, Cmd msg )
clickedCheckbox model id items =
    let
        _ =
            Debug.log "checked this item" id
    in
    ( model, Cmd.none )


filterItems : String -> List ToDoItem -> List ToDoItem
filterItems textInput listOfItems =
    let
        filteredItems =
            List.filter (\item -> String.contains textInput item.title) listOfItems
    in
    filteredItems


mapFilteredItems : String -> List ToDoItem -> List (Html Msg)
mapFilteredItems searchedText toDoItems =
    let
        searchedItems =
            filterItems searchedText toDoItems

        mappedSearchedItems =
            List.map
                (\item ->
                    itemDiv
                        [ input [ Attributes.type_ "checkbox", Attributes.checked item.completed, HtmlEvents.onClick (ClickedCheckbox item.id toDoItems) ] []
                        , textDiv [ text item.title ]
                        ]
                )
                searchedItems
    in
    mappedSearchedItems


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchResponse response ->
            ( { model | initToDoItems = response }
            , Cmd.none
            )

        ToggledToDoList ->
            ( toggleToDoList model
            , Cmd.none
            )

        ClickedCheckbox id items ->
            clickedCheckbox model id items

        TextInput input ->
            ( { model | searchedText = input }
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


viewToDos : Model -> Html Msg
viewToDos { initToDoItems, showingItems, searchedText } =
    case initToDoItems of
        RemoteData.NotAsked ->
            styledText [ text "press the button to view to do list" ]

        RemoteData.Loading ->
            styledText [ text "loading items..." ]

        RemoteData.Failure _ ->
            styledText [ text "loading items failed..." ]

        RemoteData.Success items ->
            if showingItems == True then
                div []
                    [ wrapper [ styledInput TextInput "Search items..." [] ]
                    , div [] (mapFilteredItems searchedText items)
                    ]

            else
                styledText [ text "click button to show the list" ]



-- viewToDoList : List ToDoItem -> List (Html Msg)
-- viewToDoList toDoItems =
--     let
--         mappedItems =
--             List.map
--                 (\item ->
--                     itemDiv
--                         [ input [ Attributes.type_ "checkbox", Attributes.checked item.completed, HtmlEvents.onClick (ClickedCheckbox item.id toDoItems) ] []
--                         , textDiv [ text item.title ]
--                         ]
--                 )
--                 toDoItems
--     in
--     mappedItems
---- PROGRAM ----


main : Program Config Model Msg
main =
    Browser.element
        { view = view >> HtmlStyled.toUnstyled
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }

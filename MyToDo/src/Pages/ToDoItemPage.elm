port module Pages.ToDoItemPage exposing (Model, Msg, init, update, view)

import Html.Styled as HtmlStyled
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as HtmlEvents
import Http
import Json.Encode as Encode
import RemoteData
import Styled
import ToDoItems as Items


port storeItems : Encode.Value -> Cmd msg


type Msg
    = FetchResponse (RemoteData.WebData (List Items.ToDoItem))
    | ToggledToDoList
    | ClickedCompleteToDoItem Int Bool
    | InsertedSearchedText String
    | ClickedInitialState


type alias Model =
    { toDoItemsWebData : RemoteData.WebData (List Items.ToDoItem)
    , toDoItems : List Items.ToDoItem
    , showingItems : Bool
    , searchedText : String
    }


init : List Items.ToDoItem -> ( Model, Cmd Msg )
init toDoItems =
    ( { toDoItemsWebData = RemoteData.NotAsked
      , toDoItems = toDoItems
      , showingItems = False
      , searchedText = ""
      }
    , Cmd.none
    )


toggleToDoList : Model -> Model
toggleToDoList model =
    { model | showingItems = not model.showingItems }


fetchToDoItems : String -> Cmd Msg
fetchToDoItems baseApiUrl =
    Http.get
        { url = baseApiUrl ++ "todos"
        , expect = Http.expectJson (\response -> response |> RemoteData.fromResult |> FetchResponse) Items.decodeToDoItems
        }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model baseApiUrl =
    case msg of
        FetchResponse response ->
            ( { model
                | toDoItemsWebData = response
                , toDoItems = RemoteData.withDefault model.toDoItems response
              }
              -- always ()
            , Cmd.none
            )

        ToggledToDoList ->
            ( toggleToDoList model
            , Cmd.none
            )

        ClickedCompleteToDoItem id completed ->
            let
                updatedToDoItem item =
                    if item.id == id then
                        { item | completed = completed }

                    else
                        item

                updatedToDoItems =
                    List.map updatedToDoItem model.toDoItems
            in
            ( { model | toDoItems = updatedToDoItems }
            , storeItems <| Items.encodeToDoItems updatedToDoItems
            )

        InsertedSearchedText searchedText ->
            ( { model | searchedText = searchedText }
            , Cmd.none
            )

        ClickedInitialState ->
            ( { model | toDoItemsWebData = RemoteData.Loading, showingItems = True }
            , fetchToDoItems baseApiUrl
            )


buttonTitle : Model -> String
buttonTitle { showingItems } =
    if showingItems then
        "Hide list"

    else
        "Show list"


renderToDoItems : Model -> List (HtmlStyled.Html Msg)
renderToDoItems { searchedText, toDoItems } =
    toDoItems
        |> Items.filterItems searchedText
        |> List.map
            (\item ->
                Styled.itemDiv
                    [ HtmlStyled.input
                        [ Attributes.type_ "checkbox"
                        , Attributes.checked item.completed
                        , HtmlEvents.onCheck <| ClickedCompleteToDoItem item.id
                        ]
                        []
                    , Styled.textDiv [ HtmlStyled.text item.title ]
                    ]
            )


viewToDos : Model -> HtmlStyled.Html Msg
viewToDos model =
    HtmlStyled.div []
        [ case model.toDoItemsWebData of
            RemoteData.NotAsked ->
                Styled.styledText [ HtmlStyled.text "" ]

            RemoteData.Loading ->
                Styled.styledText [ HtmlStyled.text "loading items..." ]

            RemoteData.Failure _ ->
                Styled.styledText [ HtmlStyled.text "loading items failed..." ]

            RemoteData.Success _ ->
                HtmlStyled.div [] []
        , if model.showingItems then
            HtmlStyled.div
                []
                [ Styled.wrapper [ Styled.styledInput InsertedSearchedText "Search items..." [] ]
                , HtmlStyled.div [] (renderToDoItems model)
                ]

          else
            Styled.styledText [ HtmlStyled.text "click button to show the list" ]
        ]


view : Model -> HtmlStyled.Html Msg
view model =
    HtmlStyled.div []
        [ HtmlStyled.img [ Attributes.src "/logo.png" ] []
        , Styled.styledh1 [ HtmlStyled.text "welcome to: to do app 3000!" ]
        , Styled.btn Styled.Red ToggledToDoList [ HtmlStyled.text (buttonTitle model) ]
        , Styled.btn Styled.Blue ClickedInitialState [ HtmlStyled.text "initial state" ]
        , Styled.wrapper [ Styled.itemWrapper [ viewToDos model ] ]
        ]

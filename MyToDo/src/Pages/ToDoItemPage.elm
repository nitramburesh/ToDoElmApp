module Pages.ToDoItemPage exposing (Model, Msg, init, update, view)

import Api
import Html.Styled as HtmlStyled
import Html.Styled.Attributes as Attributes
import RemoteData
import Styled
import Taco
import TimeModule
import ToDoItems as Items
import Translations


type Msg
    = FetchResponse (RemoteData.WebData (List Items.ToDoItem))
    | ToggledToDoList
    | ClickedCompleteToDoItem Int Bool
    | InsertedSearchedText String
    | ClickedInitialState
    | InsertedToken String


type Model
    = ModelInternal ModelInternalPayload


type alias ModelInternalPayload =
    { toDoItemsWebData : RemoteData.WebData (List Items.ToDoItem)
    , toDoItems : List Items.ToDoItem
    , showingItems : Bool
    , searchedText : String
    }


init : List Items.ToDoItem -> ( Model, Cmd Msg )
init toDoItems =
    ( ModelInternal
        { toDoItemsWebData = RemoteData.NotAsked
        , toDoItems = toDoItems
        , showingItems = False
        , searchedText = ""
        }
    , Cmd.none
    )


toggleToDoList : ModelInternalPayload -> ModelInternalPayload
toggleToDoList model =
    { model | showingItems = not model.showingItems, searchedText = "" }


fetchToDoItems : Api.Api -> Cmd Msg
fetchToDoItems api =
    Api.get Items.decodeToDoItems FetchResponse "todos" api


update : Msg -> Model -> Taco.Taco -> ( Model, Cmd Msg, Taco.Msg )
update msg (ModelInternal model) sharedState =
    case msg of
        FetchResponse response ->
            ( ModelInternal
                { model
                    | toDoItemsWebData = response
                    , toDoItems = RemoteData.withDefault model.toDoItems response
                }
              -- always ()
            , Cmd.none
            , Taco.NoUpdate
            )

        ToggledToDoList ->
            ( ModelInternal <| toggleToDoList model
            , Cmd.none
            , Taco.NoUpdate
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
            ( ModelInternal { model | toDoItems = updatedToDoItems }
            , Items.storeItems <| Items.encodeToDoItems updatedToDoItems
            , Taco.NoUpdate
            )

        InsertedSearchedText searchedText ->
            ( ModelInternal { model | searchedText = searchedText }
            , Cmd.none
            , Taco.NoUpdate
            )

        ClickedInitialState ->
            ( ModelInternal { model | toDoItemsWebData = RemoteData.Loading, showingItems = True }
            , fetchToDoItems (Taco.getApi sharedState)
            , Taco.NoUpdate
            )

        InsertedToken accessToken ->
            ( ModelInternal model
            , Cmd.none
            , Taco.SetAccessToken accessToken
            )


buttonTitle : ModelInternalPayload -> Taco.Taco -> String
buttonTitle { showingItems } sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
    in
    if showingItems then
        t "buttons.hideList"

    else
        t "buttons.showList"


renderToDoItems : ModelInternalPayload -> List (HtmlStyled.Html Msg)
renderToDoItems { searchedText, toDoItems } =
    toDoItems
        |> Items.filterItems searchedText
        |> List.map
            (\item ->
                Styled.itemDiv
                    [ Styled.checkbox
                        item.completed
                        (ClickedCompleteToDoItem item.id)
                        []
                    , Styled.textDiv [ HtmlStyled.text item.title ]
                    ]
            )


viewToDos : ModelInternalPayload -> Taco.Taco -> HtmlStyled.Html Msg
viewToDos model sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
    in
    HtmlStyled.div []
        [ case model.toDoItemsWebData of
            RemoteData.NotAsked ->
                Styled.styledText [ HtmlStyled.text "" ]

            RemoteData.Loading ->
                Styled.styledText [ HtmlStyled.text (t "text.loading") ]

            RemoteData.Failure _ ->
                Styled.styledText [ HtmlStyled.text (t "text.loadingFailed") ]

            RemoteData.Success _ ->
                HtmlStyled.div [] []
        , if model.showingItems then
            HtmlStyled.div
                []
                [ Styled.wrapper [ Styled.styledInput InsertedSearchedText (t "placeholders.searchItems") [] ]
                , HtmlStyled.div [] (renderToDoItems model)
                ]

          else
            Styled.styledText [ HtmlStyled.text (t "text.showListMessage") ]
        ]


view : Model -> Taco.Taco -> HtmlStyled.Html Msg
view (ModelInternal modelInternalPayload) sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
    in
    HtmlStyled.div []
        [ Styled.centeredWrapper
            [ Styled.styledh1 [ HtmlStyled.text (t "text.welcomeHeading") ]
            , HtmlStyled.img [ Attributes.src "/logo.png" ] []
            , setAccessTokenView sharedState
            ]
        , Styled.btn Styled.RedSquare ToggledToDoList [ HtmlStyled.text (buttonTitle modelInternalPayload sharedState) ]
        , Styled.btn Styled.BlueSquare
            ClickedInitialState
            [ HtmlStyled.text (t "buttons.initialState") ]
        , Styled.wrapper [ Styled.itemsWrapper [ viewToDos modelInternalPayload sharedState ] ]
        ]


setAccessTokenView : Taco.Taco -> HtmlStyled.Html Msg
setAccessTokenView sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
    in
    Styled.centeredWrapper
        [ Styled.styledInput
            InsertedToken
            (t "placeholders.insertToken")
            []
        ]

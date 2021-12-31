module Pages.ToDoItemPage exposing (Model, Msg, init, update, view)

import Api
import Html.Styled as HtmlStyled
import RemoteData
import Styled 
import Taco
import ToDoItems as Items
import Translations



--- MODEL ---


type Model
    = ModelInternal ModelInternalPayload


type alias ModelInternalPayload =
    { toDoItemsWebData : RemoteData.WebData (List Items.ToDoItem)
    , toDoItems : List Items.ToDoItem
    , showingItems : Bool
    , searchedText : String
    , idCount : Int
    , itemTitleToAdd : String
    , isHoveringOnItem : Bool
    }



--- INIT ---


init : List Items.ToDoItem -> ( Model, Cmd Msg )
init toDoItems =
    ( ModelInternal
        { toDoItemsWebData = RemoteData.NotAsked
        , toDoItems = toDoItems
        , showingItems = True
        , idCount = List.length toDoItems
        , itemTitleToAdd = ""
        , searchedText = ""
        , isHoveringOnItem = False
        }
    , Cmd.none
    )



--- UPDATE ---


type Msg
    = FetchResponse (RemoteData.WebData (List Items.ToDoItem))
    | ToggledToDoList
    | ClickedCompleteToDoItem Int Bool
    | InsertedSearchedText String
    | ClickedInitialState
    | InsertedToken String
    | InsertedToDoItem String
    | AddToDoItem String
    | DeletedItem Items.ToDoItem
    | ToggleDeleteButton Items.ToDoItem


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
            let
                cmdMessage =
                    if model.toDoItems == [] then
                        fetchToDoItems (Taco.getApi sharedState)

                    else
                        Cmd.none
            in
            ( ModelInternal <| toggleToDoList model
            , cmdMessage
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

        InsertedToDoItem itemTitle ->
            let
                updatedModel =
                    { model | itemTitleToAdd = itemTitle }
            in
            ( ModelInternal updatedModel
            , Cmd.none
            , Taco.NoUpdate
            )

        AddToDoItem itemTitle ->
            let
                id =
                    List.length model.toDoItems + 1

                item =
                    { title = itemTitle, completed = False, id = id, showingDeleteButton = False }

                updatedToDoItems =
                    model.toDoItems
                        |> List.append [ item ]

                updatedModel =
                    { model | toDoItems = updatedToDoItems, itemTitleToAdd = "", idCount = id }
            in
            ( ModelInternal updatedModel
            , Cmd.none
            , Taco.NoUpdate
            )

        DeletedItem clickedItem ->
            let
                filteredItems =
                    model.toDoItems
                        |> List.filter (\item -> item /= clickedItem)

                updatedModel =
                    { model | toDoItems = filteredItems }
            in
            ( ModelInternal updatedModel
            , Cmd.none
            , Taco.NoUpdate
            )

        ToggleDeleteButton hoveredItem ->
            let
                updatedItems =
                    model.toDoItems
                        |> List.map (
                            \item -> 
                                if item == hoveredItem then 
                                    Items.toggleDeleteButton hoveredItem
                                else 
                                    item
                                )
                    
                updatedModel =
                    { model | toDoItems = updatedItems }
            in
            ( ModelInternal updatedModel
            , Cmd.none
            , Taco.NoUpdate
            )



--- HELPER FUNCTIONS ---


toggleToDoList : ModelInternalPayload -> ModelInternalPayload
toggleToDoList model =
    { model | showingItems = not model.showingItems, searchedText = "" }


fetchToDoItems : Api.Api -> Cmd Msg
fetchToDoItems api =
    Api.get Items.decodeToDoItems FetchResponse "todos" api


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
renderToDoItems model =
    model.toDoItems
        |> Items.filterItems model.searchedText
        |> List.map
            (\item ->
                Styled.itemDiv (ToggleDeleteButton item)
                    [ Styled.checkbox
                        item.completed
                        (ClickedCompleteToDoItem item.id)
                        []
                    , Styled.textDiv [ HtmlStyled.text item.title ]
                    , showDeleteButtonOnHover item
                    ]
            )


showDeleteButtonOnHover : Items.ToDoItem -> HtmlStyled.Html Msg
showDeleteButtonOnHover item =
    if item.showingDeleteButton then
        Styled.btn Styled.Delete (DeletedItem item) [ HtmlStyled.text "delete" ]

    else
        HtmlStyled.text ""


setAccessTokenView : Taco.Taco -> HtmlStyled.Html Msg
setAccessTokenView sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)

        value =
            Api.getAccessToken (Taco.getApi sharedState)
    in
    Styled.centeredWrapper
        [ Styled.inputOnInput
            InsertedToken
            value
            (t "placeholders.insertToken")
            []
        ]



--- VIEWS ---


viewToDos : ModelInternalPayload -> Taco.Taco -> HtmlStyled.Html Msg
viewToDos model sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)

        searchedText =
            model.searchedText

        itemTitle =
            model.itemTitleToAdd
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
                [ Styled.centeredWrapper
                    [ Styled.inputOnInput InsertedSearchedText searchedText (t "placeholders.searchItems") []
                    , Styled.addItemsWrapper
                        [ Styled.inputOnInput InsertedToDoItem itemTitle (t "placeholders.addItem") []
                        , Styled.btn Styled.Blue (AddToDoItem model.itemTitleToAdd) [ HtmlStyled.text "+" ]
                        ]
                    ]
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
            , Styled.heroLogo "/logo.png" []
            , setAccessTokenView sharedState
            ]
        , Styled.btn Styled.BlueSquare ToggledToDoList [ HtmlStyled.text (buttonTitle modelInternalPayload sharedState) ]
        , Styled.btn Styled.BlueSquare
            ClickedInitialState
            [ HtmlStyled.text (t "buttons.loadItems") ]
        , Styled.wrapper [ Styled.itemsWrapper [ viewToDos modelInternalPayload sharedState ] ]
        ]

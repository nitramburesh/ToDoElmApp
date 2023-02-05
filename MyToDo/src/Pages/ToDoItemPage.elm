module Pages.ToDoItemPage exposing (Model, Msg, init, update, view)

import Api
import Html
import Html.Attributes
import Html.Styled as HtmlStyled
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Decode
import Process
import RemoteData
import Styled
import Taco
import Task
import ToDoItems as Items
import Toast
import Translations



--- MODEL ---


type Model
    = ModelInternal ModelInternalPayload


type FilterTabs
    = Done
    | NotDone
    | All


type alias ModelInternalPayload =
    { toDoItemsWebData : RemoteData.WebData (List Items.ToDoItem)
    , toDoItems : List Items.ToDoItem
    , showingItems : Bool
    , searchedText : String
    , idCount : Int
    , itemTitleToAdd : String
    , tray : Toast.Tray Styled.Toast
    , selectedFilterTab : FilterTabs
    }



--- INIT ---


delay : Int -> msg -> Cmd msg
delay ms msg =
    Task.perform (always msg) (Process.sleep <| toFloat ms)


init : List Items.ToDoItem -> ( Model, Cmd Msg )
init toDoItems =
    ( ModelInternal
        { toDoItemsWebData = RemoteData.NotAsked
        , toDoItems = toDoItems
        , showingItems = True
        , idCount = List.length toDoItems
        , itemTitleToAdd = ""
        , searchedText = ""
        , tray = Toast.tray
        , selectedFilterTab = All
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
      -- | ToggleDeleteButton Items.ToDoItem
    | DeletedAllItems
    | ToastMsg Toast.Msg
    | AddToast Styled.Toast
    | SelectedFilterTab FilterTabs


update : Msg -> Model -> Taco.Taco -> ( Model, Cmd Msg, Taco.Msg )
update msg (ModelInternal model) sharedState =
    case msg of
        FetchResponse response ->
            let
                unwrappedItems =
                    RemoteData.withDefault model.toDoItems response
            in
            ( ModelInternal
                { model
                    | toDoItemsWebData = response
                    , toDoItems = unwrappedItems
                }
              -- always ()
            , storeToDosCmd unwrappedItems
            , Taco.NoUpdate
            )

        ToggledToDoList ->
            ( ModelInternal <| toggleToDoList model
            , storeToDosCmd model.toDoItems
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
            , storeToDosCmd updatedToDoItems
            , Taco.NoUpdate
            )

        InsertedSearchedText searchedText ->
            ( ModelInternal { model | searchedText = searchedText }
            , Cmd.none
            , Taco.NoUpdate
            )

        ClickedInitialState ->
            let
                toastCmd =
                    delay 0 (AddToast { message = "items successfully added!", color = Styled.GreenToast })

                fetchCmd =
                    fetchToDoItems (Taco.getApi sharedState)
            in
            ( ModelInternal { model | toDoItemsWebData = RemoteData.Loading, showingItems = True }
            , Cmd.batch [ toastCmd, fetchCmd ]
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
                    { model | itemTitleToAdd = itemTitle, searchedText = "" }
            in
            ( ModelInternal updatedModel
            , Cmd.none
            , Taco.NoUpdate
            )

        AddToDoItem itemTitle ->
            let
                isNotEmptyTitle =
                    String.length itemTitle /= 0

                id =
                    List.length model.toDoItems + 1

                item =
                    { title = itemTitle, completed = False, id = id }

                updatedToDoItems =
                    item :: model.toDoItems

                updatedModel =
                    if isNotEmptyTitle then
                        { model | toDoItems = updatedToDoItems, itemTitleToAdd = "", idCount = id }

                    else
                        model

                storeCmd =
                    if isNotEmptyTitle then
                        storeToDosCmd updatedToDoItems

                    else
                        Cmd.none

                toastCmd =
                    if isNotEmptyTitle then
                        delay 0 (AddToast { message = "item successfully added!", color = Styled.GreenToast })

                    else
                        delay 0 (AddToast { message = "title is empty, this item is useless...", color = Styled.RedToast })
            in
            ( ModelInternal updatedModel
            , Cmd.batch [ storeCmd, toastCmd ]
            , Taco.NoUpdate
            )

        DeletedItem clickedItem ->
            let
                filteredItems =
                    model.toDoItems
                        |> List.filter (\item -> item /= clickedItem)

                updatedModel =
                    { model | toDoItems = filteredItems }

                storeCmd =
                    storeToDosCmd filteredItems

                toastCmd =
                    delay 0 (AddToast { message = "item deleted", color = Styled.DarkToast })
            in
            ( ModelInternal updatedModel
            , Cmd.batch [ storeCmd, toastCmd ]
            , Taco.NoUpdate
            )

        DeletedAllItems ->
            let
                deletedItems =
                    []

                updatedModel =
                    { model | toDoItems = deletedItems }

                storeCmd =
                    storeToDosCmd deletedItems

                toastCmd =
                    if List.length model.toDoItems /= 0 then
                        delay 0 (AddToast { message = "items deleted!", color = Styled.DarkToast })

                    else
                        delay 0 (AddToast { message = "no items to delete!", color = Styled.RedToast })
            in
            ( ModelInternal updatedModel
            , Cmd.batch [ toastCmd, storeCmd ]
            , Taco.NoUpdate
            )

        AddToast content ->
            let
                ( tray, toastMsg ) =
                    Toast.addUnique model.tray
                        (Toast.expireIn 2000 content)
            in
            ( ModelInternal { model | tray = tray }
            , Cmd.map ToastMsg toastMsg
            , Taco.NoUpdate
            )

        ToastMsg tmsg ->
            let
                ( tray, newToastMsg ) =
                    Toast.update tmsg model.tray
            in
            ( ModelInternal { model | tray = tray }
            , Cmd.map ToastMsg newToastMsg
            , Taco.NoUpdate
            )

        SelectedFilterTab tab ->
            let
                updatedModel =
                    { model | selectedFilterTab = tab }
            in
            ( ModelInternal updatedModel
            , Cmd.none
            , Taco.NoUpdate
            )



--- HELPER FUNCTIONS ---


selectFilterTab : ModelInternalPayload -> FilterTabs -> ModelInternalPayload
selectFilterTab model tabName =
    { model | selectedFilterTab = tabName }


onEnter : Msg -> HtmlStyled.Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg

            else
                Json.Decode.fail "not ENTER"
    in
    Events.on "keydown" (Json.Decode.andThen isEnter Events.keyCode)


onInput : (String -> Msg) -> String -> HtmlStyled.Attribute Msg
onInput tagger string =
    let
        decodedString =
            Json.Decode.succeed string
    in
    Events.on "input" (Json.Decode.map tagger decodedString)


storeToDosCmd : List Items.ToDoItem -> Cmd Msg
storeToDosCmd items =
    Items.storeItems <| Items.encodeToDoItems items


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


renderToDoItems : ModelInternalPayload -> Taco.Taco -> List (HtmlStyled.Html Msg)
renderToDoItems model sharedState =
    case model.selectedFilterTab of
        All ->
            model.toDoItems
                |> Items.filterItems model.searchedText
                |> List.map
                    (\item ->
                        Styled.itemDiv
                            [ Styled.checkbox
                                item.completed
                                (ClickedCompleteToDoItem item.id)
                                []
                            , Styled.textDiv [ HtmlStyled.text item.title ]
                            , showDeleteButton item sharedState
                            ]
                    )

        Done ->
            model.toDoItems
                |> Items.filterItems model.searchedText
                |> List.map
                    (\item ->
                        if item.completed then
                            Styled.itemDiv
                                [ Styled.checkbox
                                    item.completed
                                    (ClickedCompleteToDoItem item.id)
                                    []
                                , Styled.textDiv [ HtmlStyled.text item.title ]
                                , showDeleteButton item sharedState
                                ]

                        else
                            HtmlStyled.text ""
                    )

        NotDone ->
            model.toDoItems
                |> Items.filterItems model.searchedText
                |> List.map
                    (\item ->
                        if not item.completed then
                            Styled.itemDiv
                                [ Styled.checkbox
                                    item.completed
                                    (ClickedCompleteToDoItem item.id)
                                    []
                                , Styled.textDiv [ HtmlStyled.text item.title ]
                                , showDeleteButton item sharedState
                                ]

                        else
                            HtmlStyled.text ""
                    )


showDeleteButton : Items.ToDoItem -> Taco.Taco -> HtmlStyled.Html Msg
showDeleteButton item sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
    in
    Styled.deleteHoverButton (DeletedItem item) [ HtmlStyled.text (t "buttons.deleteItem") ]


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
                    [ viewFilterButtons model.selectedFilterTab
                    , Styled.inputOnInput InsertedSearchedText searchedText (t "placeholders.searchItems") []
                    , Styled.addItemsWrapper
                        [ Styled.customInputOnInput
                            [ Events.onInput InsertedToDoItem
                            , Attributes.value itemTitle
                            , onEnter (AddToDoItem itemTitle)
                            , Attributes.placeholder (t "placeholders.addItem")
                            ]
                            []
                        , Styled.btn Styled.Blue (AddToDoItem model.itemTitleToAdd) [ HtmlStyled.text "+" ]
                        ]
                    ]
                , HtmlStyled.div [] (renderToDoItems model sharedState)
                ]

          else
            Styled.styledText [ HtmlStyled.text (t "text.showListMessage") ]
        ]


view : Model -> Taco.Taco -> HtmlStyled.Html Msg
view (ModelInternal model) sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)

        toast =
            Toast.config ToastMsg
                |> Toast.withTransitionAttributes [ Html.Attributes.class "toast-fade-out" ]
                |> Toast.render viewToast model.tray
    in
    HtmlStyled.div []
        [ Styled.centeredWrapper
            [ Styled.styledh1 [ HtmlStyled.text (t "text.welcomeHeading") ]

            -- , Styled.heroLogo "/logo.png" []
            , setAccessTokenView sharedState
            ]
        , Styled.btn Styled.BlueSquare ToggledToDoList [ HtmlStyled.text (buttonTitle model sharedState) ]
        , Styled.btn Styled.BlueSquare ClickedInitialState [ HtmlStyled.text (t "buttons.loadItems") ]
        , Styled.btn Styled.BlueSquare DeletedAllItems [ HtmlStyled.text (t "buttons.deleteAllItems") ]
        , HtmlStyled.fromUnstyled toast
        , Styled.wrapper [ Styled.itemsWrapper [ viewToDos model sharedState ] ]
        ]


viewToast : List (Html.Attribute Msg) -> Toast.Info Styled.Toast -> Html.Html Msg
viewToast attributes toast =
    Html.div
        (Styled.toastStyles toast ++ attributes)
        [ Html.text toast.content.message ]


viewFilterButtons : FilterTabs -> HtmlStyled.Html Msg
viewFilterButtons selectedFilterTab =
    let
        isSelected tab =
            if tab == selectedFilterTab then
                True

            else
                False
    in
    HtmlStyled.div []
        [ Styled.filterButton (isSelected All) (SelectedFilterTab All) [ HtmlStyled.text "all" ]
        , Styled.filterButton (isSelected Done) (SelectedFilterTab Done) [ HtmlStyled.text "done" ]
        , Styled.filterButton (isSelected NotDone) (SelectedFilterTab NotDone) [ HtmlStyled.text "not done" ]
        ]

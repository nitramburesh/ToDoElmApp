module Main exposing (..)

import Api
import Browser
import Browser.Navigation as Nav
import Header
import Html.Styled as HtmlStyled
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Pages.NotFoundPage as NotFoundPage
import Pages.ToDoItemPage as ToDoItemPage
import Router
import Styled
import Taco
import Time
import ToDoItems as Items
import Translations
import Url
import Task



---- MODEL ----


type alias RawFlags =
    Encode.Value


type alias Flags =
    { baseApiUrl : String
    , toDoItems : List Items.ToDoItem
    , accessToken : String
    , translations : Translations.Model
    }


type Model
    = Ready ReadyModel Page
    | FlagsError


type alias ReadyModel =
    { flags : Flags
    , sharedState : Taco.Taco
    , showingTranslations : Bool
    }


type Page
    = ToDoItemPage ToDoItemPage.Model
    | NextPage ToDoItemPage.Model
    | NotFoundPage



---- UPDATE ----


type Msg
    = ToDoItemPageMsg ToDoItemPage.Msg
    | NextPageMsg ToDoItemPage.Msg
    | HeaderMsg Header.Msg
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Redirect Router.Route
    | ChangedLanguage Translations.Language
    | ClickedShowLanguageButtons Bool
    | Tick Time.Posix


init : RawFlags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init rawFlags url key =
    case Decode.decodeValue decodeFlags rawFlags of
        Ok flags ->
            let
                api =
                    Api.init flags

                readyModel =
                    { flags = flags
                    , sharedState = Taco.init flags.translations api key (Time.millisToPosix 0)
                    , showingTranslations = False
                    }

                ( page, pageCmd ) =
                    url
                        |> Router.parseUrl
                        |> routeToPage readyModel
            in
            ( Ready readyModel page
            , pageCmd
            )

        Err _ ->
            ( FlagsError
            , Cmd.none
            )


decodeFlags : Decode.Decoder Flags
decodeFlags =
    Decode.succeed Flags
        |> Pipeline.required "baseApiUrl" Decode.string
        |> Pipeline.optional "toDoItems" Items.decodeToDoItems Items.initialToDoItems
        |> Pipeline.required "accessToken" Decode.string
        |> Pipeline.required "translations" Translations.decode


routeToPage : ReadyModel -> Maybe Router.Route -> ( Page, Cmd Msg )
routeToPage { sharedState, flags } route =
    case route of
        Just Router.ToDoItemRoute ->
            let
                ( toDoItemPageModel, toDoItemPageCmd ) =
                    ToDoItemPage.init flags.toDoItems
            in
            ( ToDoItemPage toDoItemPageModel
            , Cmd.map ToDoItemPageMsg toDoItemPageCmd
            )

        Just Router.NextPageRoute ->
            let
                ( nextPageModel, nextPageCmd ) =
                    ToDoItemPage.init flags.toDoItems
            in
            ( NextPage nextPageModel
            , Cmd.map NextPageMsg nextPageCmd
            )

        Nothing ->
            let
                ( toDoItemPageModel, _ ) =
                    ToDoItemPage.init flags.toDoItems
            in
            ( ToDoItemPage toDoItemPageModel
            , Nav.replaceUrl (Taco.getKey sharedState) <| Router.routeToString Router.ToDoItemRoute
            )


redirect : ReadyModel -> Router.Route -> Cmd Msg
redirect { sharedState } route =
    let
        routeString =
            Router.routeToString route
    in
    Nav.replaceUrl (Taco.getKey sharedState) routeString


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LinkClicked urlRequest, Ready { sharedState } _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Taco.getKey sharedState) <| Url.toString url
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( UrlChanged url, Ready readyModel _ ) ->
            let
                ( page, _ ) =
                    url
                        |> Router.parseUrl
                        |> routeToPage readyModel
            in
            ( Ready readyModel page
            , Cmd.none
            )

        ( ToDoItemPageMsg subMsg, Ready readyModel (ToDoItemPage subModel) ) ->
            let
                ( updatedPageModel, pageCmd, sharedStateMsg ) =
                    ToDoItemPage.update subMsg subModel readyModel.sharedState

                updatedTaco =
                    Taco.update sharedStateMsg readyModel.sharedState

                page =
                    ToDoItemPage updatedPageModel

                updatedReadyModel =
                    { readyModel | sharedState = updatedTaco }
            in
            ( Ready updatedReadyModel page
            , Cmd.map ToDoItemPageMsg pageCmd
            )

        ( NextPageMsg subMsg, Ready readyModel (NextPage submodel) ) ->
            let
                ( updatedPageModel, pageCmd, sharedStateMsg ) =
                    ToDoItemPage.update subMsg submodel readyModel.sharedState

                updatedTaco =
                    Taco.update sharedStateMsg readyModel.sharedState

                page =
                    NextPage updatedPageModel

                updatedReadyModel =
                    { readyModel | sharedState = updatedTaco }
            in
            ( Ready updatedReadyModel page
            , Cmd.map NextPageMsg pageCmd
            )

        ( HeaderMsg subMsg, Ready readyModel page) ->
            let
                ( pageCmd, sharedStateMsg ) =
                    Header.update subMsg readyModel.sharedState
            
                updatedTaco = 
                    Taco.update sharedStateMsg readyModel.sharedState

                updatedReadyModel =
                    { readyModel | sharedState = updatedTaco }
            in
            ( Ready updatedReadyModel page , Cmd.map HeaderMsg pageCmd)

        ( Redirect route, Ready readyModel _ ) ->
            ( model, redirect readyModel route )

        ( ChangedLanguage language, Ready readyModel page ) ->
            let
                updatedTranslations =
                    Translations.changeLanguage language (Taco.getTranslations readyModel.sharedState)

                updatedTaco =
                    Taco.updateTranslations readyModel.sharedState updatedTranslations

                updatedModel =
                    { readyModel | sharedState = updatedTaco, showingTranslations = False }
            in
            ( Ready updatedModel page, Cmd.none )

        ( ClickedShowLanguageButtons isShowing, Ready readyModel page ) ->
            let
                updatedModel =
                    { readyModel | showingTranslations = not isShowing }
            in
            ( Ready updatedModel page, Cmd.none )
        (Tick currentTime, Ready readyModel page) ->
            let 
                updatedTaco = 
                    Taco.updateTime readyModel.sharedState currentTime
                updatedModel =
                    { readyModel | sharedState = updatedTaco}
            in
                ( Ready updatedModel page, Cmd.none)
        _ ->
            ( model
            , Cmd.none
            )



---- VIEW ----
headerView :  ReadyModel -> HtmlStyled.Html Msg
headerView  readyModel = 
    Header.navigationHeaderView readyModel.sharedState
        |> HtmlStyled.map HeaderMsg

pageView : Page -> ReadyModel -> HtmlStyled.Html Msg
pageView page { sharedState } =
    case page of
        ToDoItemPage pageModel ->
            ToDoItemPage.view pageModel sharedState
                |> HtmlStyled.map ToDoItemPageMsg

        NextPage pageModel ->
            ToDoItemPage.view pageModel sharedState
                |> HtmlStyled.map NextPageMsg

        NotFoundPage ->
            NotFoundPage.view

viewTime : ReadyModel -> HtmlStyled.Html Msg
viewTime {sharedState} =
    let
        time = Taco.getTime sharedState

        rawMinute = (Time.toMinute Time.utc time)
        rawSecond = (Time.toSecond Time.utc time)

        firstComma = 
            if rawMinute > 9 then ":"
                    else ":0"
        secondComma =
            if rawSecond > 9 then ":"
                    else ":0"

        hour   = String.fromInt (Time.toHour Time.utc time)
        minute = String.fromInt (Time.toMinute Time.utc time)
        second = String.fromInt (Time.toSecond Time.utc time)
    in 
        HtmlStyled.div[]
            [HtmlStyled.text 
                (hour ++ firstComma ++  minute ++ secondComma ++ second)]

view : Model -> Browser.Document Msg
view model =
    case model of
        Ready readyModel page ->
            case page of
                ToDoItemPage _ ->
                    { title = "ToDoItem Page"
                    , body =
                        [ [ headerView readyModel
                          , pageView page readyModel
                          ]
                            |> HtmlStyled.div []
                            |> HtmlStyled.toUnstyled
                        ]
                    }

                NextPage _ ->
                    let
                        { t } =
                            Translations.translators (Taco.getTranslations readyModel.sharedState)
                    in
                    { title = "Next Page"
                    , body =
                        [ [ headerView readyModel
                          , Styled.styledh2 [ HtmlStyled.text (t "text.thisIsNextPage") ]
                          , pageView page readyModel
                          , viewTime readyModel
                          ]
                            |> HtmlStyled.div []
                            |> HtmlStyled.toUnstyled
                        ]
                    }

                NotFoundPage ->
                    { title = "Page Not Found..."
                    , body =
                        [ [ NotFoundPage.view
                          ]
                            |> Styled.wrapper
                            |> HtmlStyled.toUnstyled
                        ]
                    }

        FlagsError ->
            { title = "Flags Error"
            , body =
                [ HtmlStyled.text "Something went wrong - flags error..."
                    |> HtmlStyled.toUnstyled
                ]
            }


externalRouteToString : ExternalRoute -> String
externalRouteToString route =
    case route of
        SeznamRoute ->
            "https://www.seznam.cz/"

        YoutubeRoute ->
            "https://www.youtube.com/"

        GoogleRoute ->
            "https://www.google.com/"

        RedditRoute ->
            "https://www.reddit.com/"


toExternalRoute : ExternalRoute -> Browser.UrlRequest
toExternalRoute externalRoute =
    let
        route =
            externalRouteToString externalRoute
    in
    Browser.External route


navigationHeaderView : ReadyModel -> HtmlStyled.Html Msg
navigationHeaderView model =
    let
        { t } =
            Translations.translators (Taco.getTranslations model.sharedState)
    in
    Styled.navbarWrapper
        [ Styled.btn Styled.Basic
            (Redirect Router.NextPageRoute)
            [ HtmlStyled.text (t "buttons.nextPage") ]
        , Styled.btn Styled.Basic
            (Redirect Router.ToDoItemRoute)
            [ HtmlStyled.text (t "buttons.home") ]
        , Styled.btn Styled.Basic
            (LinkClicked (toExternalRoute GoogleRoute))
            [ HtmlStyled.text (t "buttons.google") ]
        , translationButtonsView model
        ]


translationButtonsView : ReadyModel -> HtmlStyled.Html Msg
translationButtonsView { sharedState, showingTranslations } =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
    in
    if showingTranslations then
        Styled.centeredWrapper
            [ Styled.btn Styled.GreySquare
                (ChangedLanguage Translations.En)
                [ HtmlStyled.text (t "buttons.english") ]
            , Styled.btn Styled.GreySquare
                (ChangedLanguage Translations.Ru)
                [ HtmlStyled.text (t "buttons.russian") ]
            ]

    else
        Styled.centeredWrapper
            [ Styled.btn Styled.Blue
                (ClickedShowLanguageButtons showingTranslations)
                [ HtmlStyled.text (t "buttons.language") ]
            ]


seznamRoute : String
seznamRoute =
    "https://www.seznam.cz/"


toUtcString : Time.Posix -> String
toUtcString time =
    String.fromInt (Time.toHour Time.utc time)
        ++ (if Time.toMinute Time.utc time > 9 then
                ":"

            else
                ":0"
           )
        ++ String.fromInt (Time.toMinute Time.utc time)
        ++ (if Time.toSecond Time.utc time > 9 then
                ":"

            else
                ":0"
           )
        ++ String.fromInt (Time.toSecond Time.utc time)


type ExternalRoute
    = SeznamRoute
    | YoutubeRoute
    | GoogleRoute
    | RedditRoute


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 Tick



---- PROGRAM ----


main : Program RawFlags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }

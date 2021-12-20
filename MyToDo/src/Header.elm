module Header exposing (..)

import Browser
import Browser.Navigation as Nav
import Html.Styled as HtmlStyled
import Router
import Styled
import Taco
import Translations
import Url


type alias Model =
    { showingTranslations : Bool
    }


init : Model
init =
    { showingTranslations = False
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Redirect Router.Route
    | ChangedLanguage Translations.Language
    | ClickedShowLanguageButtons Bool





navigationHeaderView : Taco.Taco -> Model -> HtmlStyled.Html Msg
navigationHeaderView sharedState model =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
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
        , translationButtonsView sharedState model
        ]


translationButtonsView : Taco.Taco -> Model -> HtmlStyled.Html Msg
translationButtonsView sharedState { showingTranslations } =
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


type ExternalRoute
    = SeznamRoute
    | YoutubeRoute
    | GoogleRoute
    | RedditRoute


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

module Header exposing (Msg, navigationHeaderView, update)

import Html.Styled as HtmlStyled
import Router
import Styled
import Taco
import TimeModule
import Translations


type Msg
    = ChangedLanguage Translations.Language
    | ClickedShowLanguageButtons Bool


update : Msg -> Taco.Taco -> ( Cmd Msg, Taco.Msg )
update msg sharedState =
    case msg of
        ChangedLanguage translations ->
            let
                updatedTranslations =
                    Translations.changeLanguage translations (Taco.getTranslations sharedState)
            in
            ( Cmd.none, Taco.UpdatedTranslations updatedTranslations )

        ClickedShowLanguageButtons bool ->
            ( Cmd.none, Taco.UpdatedShowingTranslationsButton bool )


navigationHeaderView : Taco.Taco -> HtmlStyled.Html Msg
navigationHeaderView sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
    in
    Styled.navbarWrapper
        [ Styled.navbarLinksWrapper
            [ Styled.anchorInternal Router.NextPageRoute
                [ HtmlStyled.text (t "buttons.nextPage") ]
            , Styled.anchorInternal
                Router.ToDoItemRoute
                [ HtmlStyled.text (t "buttons.home") ]
            , Styled.anchorExternal (Router.externalRouteToString Router.GoogleRoute)
                [ HtmlStyled.text (t "buttons.google") ]
            ]
        , translationButtonsView sharedState
        , TimeModule.viewTimeWrapped sharedState
        ]


translationButtonsView : Taco.Taco -> HtmlStyled.Html Msg
translationButtonsView sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
    in
    if Taco.getShowingLanguageButtons sharedState then
        Styled.changeLanguageButtons
            [ Styled.btn Styled.GreySquare
                (ChangedLanguage Translations.En)
                [ HtmlStyled.text (t "buttons.english") ]
            , Styled.btn Styled.GreySquare
                (ChangedLanguage Translations.Ru)
                [ HtmlStyled.text (t "buttons.russian") ]
            ]

    else
        Styled.changeLanguageButtons
            [ Styled.btn Styled.Blue
                (ClickedShowLanguageButtons (Taco.getShowingLanguageButtons sharedState))
                [ HtmlStyled.text (t "buttons.language") ]
            ]

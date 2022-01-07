module Header exposing (Msg, update, view)

import Html.Styled as HtmlStyled
import Router
import Styled
import Taco
import TimeModule
import Translations
 

 


--- UPDATE ---


type Msg
    = ChangedLanguage Translations.Language
    | ClickedShowLanguageButtons Bool


update : Msg -> ( Cmd Msg, Taco.Msg )
update msg  =
    case msg of
        ChangedLanguage language ->
            ( Cmd.none, Taco.UpdatedLanguage language )

        ClickedShowLanguageButtons bool ->
            ( Cmd.none, Taco.UpdatedShowingTranslationsButton bool )



--- VIEW ---


view : Taco.Taco -> HtmlStyled.Html Msg
view sharedState =
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
        Styled.changeLanguageButtonsWrapper
            [ Styled.btn Styled.Grey
                (ChangedLanguage Translations.En)
                [ HtmlStyled.text (t "buttons.english") ]
            , Styled.btn Styled.Grey
                (ChangedLanguage Translations.Ru)
                [ HtmlStyled.text (t "buttons.russian") ]
            ]

    else
        Styled.changeLanguageButtonsWrapper
            [ Styled.btn Styled.Grey
                (ClickedShowLanguageButtons (Taco.getShowingLanguageButtons sharedState))
                [ HtmlStyled.text (t "buttons.language") ]
            ]

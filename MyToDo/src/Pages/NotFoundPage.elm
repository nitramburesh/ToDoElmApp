module Pages.NotFoundPage exposing (view)

import Html.Styled as HtmlStyled
import Router
import Styled
import Taco
import Translations



--- VIEW ---


view : Taco.Taco -> HtmlStyled.Html msg
view sharedState =
    let
        { t } =
            Translations.translators (Taco.getTranslations sharedState)
    in
    Styled.notFoundPageWrapper
        [ HtmlStyled.h1 [] [ HtmlStyled.text "OOPS..." ]
        , HtmlStyled.div [] [ HtmlStyled.text "I tried REALLY hard but couldn't find the page you were looking for, mate." ]
        , Styled.homeAnchor Router.ToDoItemRoute
            [ HtmlStyled.text (t "buttons.home") ]
        ]

module Pages.Dashboard exposing (view)

import Html.Styled as HtmlStyled
import Styled
import Taco
import Time
import Translations


view : Taco.Taco -> HtmlStyled.Html msg
view sharedState =
    let
        appWidth =
            String.fromInt <| Taco.getAppWidth sharedState

        { t } =
            Translations.translators (Taco.getTranslations sharedState)

        time =
            Taco.getTime sharedState

        zone =
            Taco.getZone sharedState

        stringifyTime =
            String.fromInt

        ( hour, minute ) =
            ( stringifyTime <| Time.toHour zone time
            , stringifyTime <| Time.toMinute zone time
            )

        formatedTime =
            hour ++ ":" ++ minute
    in
    HtmlStyled.div []
        [ Styled.centeredWrapper
            [ Styled.dashboard
                [ Styled.dashboardItem
                    [ Styled.styledText [ HtmlStyled.text <| t "text.currentTime" ]
                    , Styled.styledText [ HtmlStyled.text formatedTime ]
                    ]
                , Styled.dashboardItem
                    [ Styled.styledText [ HtmlStyled.text <| t "text.currentAppWidth" ]
                    , Styled.styledText [ HtmlStyled.text appWidth ]
                    ]
                ]
            ]
        ]

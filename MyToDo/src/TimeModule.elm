module TimeModule exposing (viewTimeAsString, viewTimeWrapped)

import Html.Styled as HtmlStyled
import Styled
import Taco
import Time



--- VIEW ---


viewTimeAsString : Taco.Taco -> String
viewTimeAsString sharedState =
    let
        time =
            Taco.getTime sharedState

        zone =
            Taco.getZone sharedState

        rawMinute =
            Time.toMinute Time.utc time

        colon =
            if rawMinute > 9 then
                ":"

            else
                ":0"

        hour =
            String.fromInt (Time.toHour zone time)

        minute =
            String.fromInt (Time.toMinute zone time)
    in
    hour ++ colon ++ minute


viewTimeWrapped : Taco.Taco -> HtmlStyled.Html msg
viewTimeWrapped sharedState =
    let
        time =
            viewTimeAsString sharedState
    in
    Styled.timeWrapper
        [ HtmlStyled.text time
        ]

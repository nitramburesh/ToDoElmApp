module Pages.NotFoundPage exposing (view)

import Html.Styled as Html exposing (Html)


view : Html msg
view =
    Html.div []
        [ Html.h1 [] [ Html.text "OOPS" ]
        , Html.div [] [ Html.text "I tried REALLY hard but couldn't find the page you were looking for, mate." ]
        ]

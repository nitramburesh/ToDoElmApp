module Styled exposing (..)

import Css exposing (..)
import Css.Media exposing (grid)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)


theme : { black : Color, white : Color, brown : Color, purpleNavy : Color, red : Color, shadow : Color, redOrange : Color }
theme =
    { black = rgb 0 0 0
    , white = rgb 255 255 255
    , purpleNavy = hex "40476D"
    , brown = hex "A47551"
    , red = hex "FC2E20"
    , redOrange = hex "FF5C4D"
    , shadow = hex "565857"
    }


btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn =
    styled button
        [ marginTop (rem 1)
        , borderStyle none
        , marginBottom (rem 1)
        , color theme.white
        , padding (rem 1)
        , borderRadius (rem 1)
        , backgroundColor theme.redOrange
        , textTransform uppercase
        , fontFamilies [ "Courier New" ]
        , fontSize (rem 1.5)
        , hover
            [ backgroundColor theme.red
            ]
        ]


itemDiv : List (Attribute msg) -> List (Html msg) -> Html msg
itemDiv =
    styled div
        [ displayFlex
        , color theme.white
        , margin (rem 1)
        ]


itemWrapper : List (Attribute msg) -> List (Html msg) -> Html msg
itemWrapper =
    styled div
        [ displayFlex
        , marginTop (rem 3)
        , marginBottom (rem 3)
        , justifyContent center
        , alignItems left
        , backgroundColor theme.brown
        , width (pct 60)
        , borderRadius (rem 3)
        , padding (rem 2)
        , boxShadow4 (rem 0.5) (rem 1) (rem 2) theme.shadow
        ]


styledh1 : List (Attribute msg) -> List (Html msg) -> Html msg
styledh1 =
    styled h1
        [ fontFamilies [ "Courier New" ]
        , textTransform uppercase
        , fontSize (rem 4)
        , letterSpacing (rem 0.2)
        ]


fetchMsg : List (Attribute msg) -> List (Html msg) -> Html msg
fetchMsg =
    styled div
        [ textTransform uppercase
        , fontFamilies [ "Courier New" ]
        , fontSize (rem 1.2)
        , color theme.white
        ]


textDiv : List (Attribute msg) -> List (Html msg) -> Html msg
textDiv =
    styled div
        [ marginLeft (rem 2)
        , fontFamilies [ "Courier New" ]
        , fontSize (rem 1.2)
        , color theme.white
        ]


wrapper : List (Attribute msg) -> List (Html msg) -> Html msg
wrapper =
    styled div
        [ displayFlex
        , justifyContent center
        ]


styledCheckBox : List (Attribute msg) -> List (Html msg) -> Html msg
styledCheckBox =
    styled input
        [ width (rem 1)
        , height (rem 1)
        ]

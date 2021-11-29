module Styled exposing (ButtonVariant(..), btn, itemDiv, itemWrapper, styledInput, styledText, styledh1, textDiv, wrapper)

import Css exposing (..)
import Html.Styled as HtmlStyled
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events


type ButtonVariant
    = Red
    | Blue


btn : ButtonVariant -> msg -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
btn variant msg =
    let
        styles =
            [ margin (rem 3)
            , borderStyle none
            , marginBottom (rem 1)
            , color theme.white
            , padding (rem 1)
            , borderRadius (rem 1)
            , textTransform uppercase
            , fontFamilies [ "Courier New" ]
            , fontSize (rem 1.5)
            ]

        variantStyles =
            case variant of
                Red ->
                    [ backgroundColor theme.redOrange
                    , hover
                        [ backgroundColor theme.red
                        ]
                    ]

                Blue ->
                    [ backgroundColor theme.purpleNavy
                    , hover
                        [ backgroundColor theme.navyBlue
                        ]
                    ]
    in
    HtmlStyled.button
        [ Attributes.css <| styles ++ variantStyles
        , Events.onClick msg
        ]


theme : { black : Color, white : Color, brown : Color, purpleNavy : Color, navyBlue : Color, red : Color, shadow : Color, redOrange : Color }
theme =
    { black = hex "000000"
    , white = hex "FFFFFF"
    , purpleNavy = hex "2E8BC0"
    , brown = hex "A47551"
    , red = hex "FC2E20"
    , redOrange = hex "FF5C4D"
    , shadow = hex "565857"
    , navyBlue = hex "05445E"
    }


itemDiv : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
itemDiv =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , color theme.white
            , margin (rem 1)
            ]
        ]


itemWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
itemWrapper =
    HtmlStyled.div
        [ Attributes.css
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
        ]


styledh1 : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
styledh1 =
    HtmlStyled.h1
        [ Attributes.css
            [ fontFamilies [ "Courier New" ]
            , textTransform uppercase
            , fontSize (rem 4)
            , letterSpacing (rem 0.2)
            ]
        ]


styledText : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
styledText =
    HtmlStyled.div
        [ Attributes.css
            [ textTransform uppercase
            , fontFamilies [ "Courier New" ]
            , fontSize (rem 1.2)
            , color theme.white
            ]
        ]


styledInput : (String -> msg) -> String -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
styledInput msg placeholder =
    HtmlStyled.input
        [ Attributes.css
            [ marginBottom (rem 3)
            , width (rem 30)
            , height (rem 2)
            , borderRadius (rem 2)
            , textAlign center
            , fontSize (rem 1)
            , fontFamilies [ "Courier New" ]
            ]
        , Events.onInput msg
        , Attributes.placeholder placeholder
        ]


textDiv : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
textDiv =
    HtmlStyled.div
        [ Attributes.css
            [ marginLeft (rem 2)
            , fontFamilies [ "Courier New" ]
            , fontSize (rem 1.2)
            , color theme.white
            , textAlign left
            ]
        ]


wrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
wrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , justifyContent center
            ]
        ]

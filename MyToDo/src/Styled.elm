module Styled exposing (ButtonVariant(..), bodyWrapper, btn, centeredMe, centeredWrapper, checkbox, externalLink, internalLink, itemDiv, itemsWrapper, navbarWrapper, styledInput, styledText, styledh1, styledh2, textDiv, timeWrapper, wrapper)

import Css exposing (..)
import Css.Transitions as Transitions
import Html.Styled as HtmlStyled
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Router


type ButtonVariant
    = Blue
    | Basic
    | RedSquare
    | BlueSquare
    | GreySquare


btn : ButtonVariant -> msg -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
btn variant msg =
    let
        styles =
            [ borderStyle none
            , color theme.white
            , padding (rem 1)
            , textTransform uppercase
            , fontFamilies [ "Courier New" ]
            , fontSize (rem 1.5)
            , cursor pointer
            ]

        variantStyles =
            case variant of
                RedSquare ->
                    [ backgroundColor theme.redOrange
                    , margin (rem 0.5)
                    , hover
                        [ backgroundColor theme.red
                        ]
                    , Transitions.transition
                        [ Transitions.backgroundColor 300
                        , Transitions.transform3 120 1000 Transitions.easeInOut
                        ]
                    ]

                GreySquare ->
                    [ backgroundColor theme.gray
                    , margin (rem 0.5)
                    , hover
                        [ backgroundColor theme.grayer
                        ]
                    , Transitions.transition
                        [ Transitions.backgroundColor 300
                        , Transitions.transform3 120 1000 Transitions.easeInOut
                        ]
                    ]

                BlueSquare ->
                    [ backgroundColor theme.blue
                    , margin (rem 0.5)
                    , hover
                        [ backgroundColor theme.navyBlue
                        ]
                    , Transitions.transition
                        [ Transitions.backgroundColor 300
                        , Transitions.transform3 120 1000 Transitions.easeInOut
                        ]
                    ]

                Blue ->
                    [ backgroundColor theme.blue
                    , margin (rem 0.5)
                    , borderRadius (rem 1.5)
                    , hover
                        [ backgroundColor theme.navyBlue
                        ]
                    , Transitions.transition
                        [ Transitions.backgroundColor 300
                        , Transitions.transform3 120 1000 Transitions.easeInOut
                        ]
                    ]

                Basic ->
                    [ backgroundColor theme.black
                    , hover
                        [ fontSize (rem 2.5)
                        ]
                    , Transitions.transition
                        [ Transitions.fontSize 300
                        , Transitions.transform3 120 1000 Transitions.easeInOut
                        ]
                    ]
    in
    HtmlStyled.button
        [ Attributes.css <| styles ++ variantStyles
        , Events.onClick msg
        ]


theme : { black : Color, white : Color, itemsWrapperColor : Color, blue : Color, navyBlue : Color, red : Color, darkShadow : Color, gray : Color, redOrange : Color, grayer : Color, lightShadow : Color }
theme =
    { black = hex "#000000"
    , white = hex "#FFFFFF"
    , blue = hex "#2E8BC0"
    , itemsWrapperColor = hex "#868B8E"
    , red = hex "#FC2E20"
    , redOrange = hex "#FF5C4D"
    , darkShadow = hex "#565857"
    , lightShadow = hex "#C0C0C0"
    , navyBlue = hex "#05445E"
    , grayer = hex "#495057"
    , gray = hex "#868B8E"
    }


itemDiv : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
itemDiv =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , color theme.white
            , margin (rem 1)
            , position relative
            ]
        ]


itemsWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
itemsWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , marginTop (rem 3)
            , marginBottom (rem 3)
            , justifyContent center
            , alignItems left
            , backgroundColor theme.itemsWrapperColor
            , width (pct 60)
            , borderRadius (rem 2)
            , padding (rem 2)
            , boxShadow4 (rem -0.5) (rem 0.8) (rem 0.5) theme.lightShadow
            ]
        ]


checkbox : Bool -> (Bool -> msg) -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
checkbox bool msg =
    HtmlStyled.input
        [ Attributes.type_ "checkbox"
        , Attributes.checked bool
        , Events.onCheck msg
        , Attributes.css
            [ cursor pointer
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


styledh2 : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
styledh2 =
    HtmlStyled.h2
        [ Attributes.css
            [ fontFamilies [ "Courier New" ]
            , textTransform uppercase
            , fontSize (rem 2)
            , letterSpacing (rem 2)
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


internalLink : Router.Route -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
internalLink route =
    HtmlStyled.a
        [ Attributes.css
            [ padding (rem 2)
            , hover
                [ backgroundColor theme.darkShadow
                , cursor pointer
                , color theme.white
                ]
            ]
        , Attributes.href <| Router.routeToString route
        ]


externalLink : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
externalLink =
    HtmlStyled.a
        [ Attributes.css
            [ padding (rem 2)
            , hover
                [ backgroundColor theme.darkShadow
                , cursor pointer
                , color theme.white
                ]
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


bodyWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
bodyWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , flexDirection column
            , justifyContent center
            ]
        ]


timeWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
timeWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , flexDirection column
            , justifyContent center
            , color theme.white
            ]
        ]


navbarWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
navbarWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , justifyContent spaceAround
            , alignItems center
            , marginBottom (rem 2)
            , padding (rem 2)
            , backgroundColor theme.black
            , boxShadow4 (rem 0) (rem 0.1) (rem 4) theme.darkShadow
            ]
        ]


centeredWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
centeredWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , justifyContent center
            , alignItems center
            ]
        ]


centeredMe : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
centeredMe =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , flexDirection column
            ]
        ]

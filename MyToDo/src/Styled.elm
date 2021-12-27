module Styled exposing (ButtonVariant(..), anchorExternal, anchorInternal, bodyWrapper, btn, navbarLinksWrapper, centeredWrapper, checkbox, externalLink, internalLink, itemDiv, itemsWrapper, navbarWrapper, styledInput, styledText, styledh1, styledh2, textDiv, timeWrapper, wrapper, changeLanguageButtons)

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



--- BASE STYLES ---


styledAnchor : List Style
styledAnchor =
    [ borderStyle none
    , color theme.white
    , textTransform uppercase
    , textDecoration overline
    , fontFamilies [ "Courier New" ]
    , fontSize (rem 1.5)
    , cursor pointer
    , backgroundColor theme.black
    , hover
        [ fontSize (rem 2.2)
        , textDecoration none
        ]
    , Transitions.transition
        [ Transitions.fontSize 300
        , Transitions.transform3 1000 1000 Transitions.easeInOut
        ]
    ]


styledSquareButton : List Style
styledSquareButton =
    []


colorTransition : Style
colorTransition =
    Transitions.transition
        [ Transitions.backgroundColor 300
        , Transitions.transform3 120 1000 Transitions.easeInOut
        ]


fontTransition : Style
fontTransition =
    Transitions.transition
        [ Transitions.fontSize 300
        , Transitions.transform3 120 1000 Transitions.easeInOut
        ]



--- COLORS ---


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



--- STYLES ---


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
            , margin (rem 1)
            ]

        variantStyles =
            case variant of
                RedSquare ->
                    [ backgroundColor theme.redOrange
                    , hover
                        [ backgroundColor theme.red
                        ]
                    , colorTransition
                    ]

                GreySquare ->
                    [ backgroundColor theme.gray
                    , hover
                        [ backgroundColor theme.grayer
                        ]
                    , colorTransition
                    ]

                BlueSquare ->
                    [ backgroundColor theme.blue
                    , hover
                        [ backgroundColor theme.navyBlue
                        ]
                    , colorTransition
                    ]

                Blue ->
                    [ backgroundColor theme.blue
                    , borderRadius (rem 1.5)
                    , hover
                        [ backgroundColor theme.navyBlue
                        ]
                    , colorTransition
                    ]

                Basic ->
                    [ backgroundColor theme.black
                    , hover
                        [ fontSize (rem 2.5)
                        ]
                    , fontTransition
                    ]
    in
    HtmlStyled.button
        [ Attributes.css <| styles ++ variantStyles
        , Events.onClick msg
        ]


anchorInternal : Router.Route -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
anchorInternal route =
    HtmlStyled.a
        [ Attributes.css
            styledAnchor
        , Router.href route
        ]


anchorExternal : String -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
anchorExternal route =
    HtmlStyled.a
        [ Attributes.css
            styledAnchor
        , Attributes.href route
        ]


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
            , justifyContent spaceBetween
            , alignItems center
            , marginBottom (rem 2)
            , padding (rem 1)
            , backgroundColor theme.black
            , boxShadow4 (rem 0) (rem 0.1) (rem 4) theme.darkShadow
            ]
        ]


centeredWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
centeredWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , flexDirection column            
            , justifyContent center
            , alignItems center
            ]
        ]


navbarLinksWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
navbarLinksWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
             , justifyContent spaceAround
            , flexDirection row
            , height (rem 2)
            , width (pct 80)
            ]
        ]

changeLanguageButtons : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
changeLanguageButtons =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
             , justifyContent center
            , flexDirection row
            , width (pct 20)
            ]
        ]

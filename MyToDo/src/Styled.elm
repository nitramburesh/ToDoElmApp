module Styled exposing (ButtonVariant(..), Toast, ToastColor(..), addItemsWrapper, anchorExternal, anchorInternal, bodyWrapper, btn, centeredWrapper, changeLanguageButtonsWrapper, checkbox, customInputOnInput, externalLink, filterButton, heroLogo, homeAnchor, inputOnInput, inputOnSubmit, internalLink, itemDiv, itemsWrapper, navbarLinksWrapper, navbarWrapper, notFoundPageWrapper, styledText, styledh1, styledh2, textDiv, timeWrapper, toastStyles, wrapper,deleteHoverButton)

import Css exposing (..)
import Css.Transitions as Transitions
import Html
import Html.Attributes
import Html.Styled as HtmlStyled
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Router
import Toast


type ButtonVariant
    = Blue
    | Basic
    | GreySquare
    | BlueSquare
    | Grey
    | RedSquare


type alias Toast =
    { message : String
    , color : ToastColor
    }


type ToastColor
    = RedToast
    | GreenToast
    | DarkToast


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


styledInput : List Style
styledInput =
    [ margin2 (rem 0.5) (rem 0)
    , alignSelf center
    , width (rem 30)
    , height (rem 2)
    , borderRadius (rem 2)
    , textAlign center
    , fontSize (rem 1)
    , fontFamilies [ "Courier New" ]
    ]


squareButton : Color -> Color -> List Style
squareButton bgColor hoverBgColor =
    [ backgroundColor bgColor
    , hover
        [ backgroundColor hoverBgColor
        ]
    , colorTransition
    ]



--- TRANSITIONS ---


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


theme : { black : Color, white : Color, itemsWrapperColor : Color, blue : Color, navyBlue : Color, red : Color, darkShadow : Color, grey : Color, redOrange : Color, greyer : Color, lightShadow : Color, transparentWhite : Color }
theme =
    { black = hex "#000000"
    , white = hex "#FFFFFF"
    , transparentWhite = hex "#FFFFFFCC"
    , blue = hex "#284560"
    , itemsWrapperColor = hex "#868B8EAA"
    , red = hex "#FC2E20"
    , redOrange = hex "#FF5C4D"
    , darkShadow = hex "#565857"
    , lightShadow = hex "#C0C0C0"
    , navyBlue = hex "#05445E"
    , greyer = hex "#495057"
    , grey = hex "#868B8E"
    }



--- BUTTONS ---


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
                GreySquare ->
                    squareButton theme.grey theme.black

                Grey ->
                    [ backgroundColor theme.grey
                    , borderRadius (rem 1)
                    , hover
                        [ backgroundColor theme.greyer
                        ]
                    , colorTransition
                    ]

                BlueSquare ->
                    squareButton theme.blue theme.black

                RedSquare ->
                    squareButton theme.red theme.black

                Blue ->
                    [ backgroundColor theme.blue
                    , borderRadius (rem 0.3)
                    , fontSize (rem 1)
                    , padding (rem 0)
                    , height (rem 2.5)
                    , width (rem 2.5)
                    , alignSelf center
                    , hover
                        [ backgroundColor theme.navyBlue
                        , fontSize (rem 2)
                        ]
                    , colorTransition
                    , fontTransition
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

deleteHoverButton : msg -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
deleteHoverButton msg =
    HtmlStyled.button  
        [Attributes.css[ borderStyle none
            , textTransform uppercase
            , fontFamilies [ "Courier New" ]
            , cursor pointer
           , margin (rem 0)
           , borderStyle none
                    , padding2 (rem 0.5) (rem 0.7)
                    , fontSize (rem 1)
                    , backgroundColor theme.black
                    , color theme.white
                    , position absolute
                    , right (rem 1)
                    , top (rem 0.6)

            
            ]
        , Attributes.class "displayOnParentHover"
        ,Events.onClick msg   
             ]
    

filterButton : Bool -> msg -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
filterButton isSelected msg =
    let
        styles =
            [ margin4 (rem 0) (rem 1) (rem 1) (rem 1)
            , padding2 (rem 0.5) (rem 0.7)
            , fontSize (rem 1)
            , textTransform uppercase
            , right (rem 1)
            , top (rem 0.6)
            , cursor pointer
            ]

        selectedStyles =
            if isSelected then
                [ backgroundColor theme.white
                , color theme.black
                ]

            else
                [ backgroundColor theme.blue
                , color theme.white
                , hover [
                    backgroundColor theme.black
                ]
                , colorTransition
                ]
    in
    HtmlStyled.button
        [ Attributes.css <| styles ++ selectedStyles
        , Events.onClick msg
        ]



--- ANCHORS ---


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


homeAnchor : Router.Route -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
homeAnchor route =
    let
        homeAnchorStyles =
            [ marginTop (rem 2)
            , hover
                [ backgroundColor theme.blue
                ]
            ]
    in
    HtmlStyled.a
        [ Attributes.css
            (homeAnchorStyles
                |> List.append styledAnchor
            )
        , Router.href route
        ]



--- IMAGES ---


heroLogo : String -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
heroLogo imgSource =
    HtmlStyled.img
        [ Attributes.src imgSource
        , Attributes.css
            [ width (rem 20)
            , margin (rem 0)
            ]
        ]



--- TEXT ---


styledh1 : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
styledh1 =
    HtmlStyled.h1
        [ Attributes.css
            [ fontFamilies [ "Courier New" ]
            , textTransform uppercase
            , fontSize (rem 4)
            , letterSpacing (rem 0.2)
            , marginTop (rem 3)
            , marginBottom (rem 0)
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



--- INPUTS ---
-- TODO: merge customInputOnInput & inputOnIn§put and refactor!!


customInputOnInput : List (HtmlStyled.Attribute msg) -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
customInputOnInput attributes =
    HtmlStyled.input
        (List.append
            [ Attributes.css styledInput ]
            attributes
        )


inputOnInput : (String -> msg) -> String -> String -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
inputOnInput msg value placeholder =
    HtmlStyled.input
        [ Attributes.css
            styledInput
        , Attributes.placeholder placeholder
        , Attributes.value value
        , Events.onInput msg
        ]


inputOnSubmit : msg -> String -> List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
inputOnSubmit msg placeholder =
    HtmlStyled.input
        [ Attributes.css
            styledInput
        , Attributes.placeholder placeholder
        , Events.onSubmit msg
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



--- LINKS ---


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



--- WRAPPERS ---


wrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
wrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , justifyContent center
            ]
        ]


addItemsWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
addItemsWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , justifyContent center
            , width (rem 30)
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


notFoundPageWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
notFoundPageWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , flexDirection column
            , marginTop (rem 10)
            ]
        ]


timeWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
timeWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , flexDirection column
            , justifyContent center
            , margin2 (rem 0) (rem 2)
            , color theme.black
            , backgroundColor theme.white
            , padding2 (rem 1) (rem 1)
            , borderRadius (rem 1)
            , boxShadow6 inset (rem -0.2) (rem 0.3) (rem 0.3) (rem 0.01) theme.lightShadow
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
            , width (pct 65)
            ]
        ]


changeLanguageButtonsWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
changeLanguageButtonsWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , justifyContent center
            , flexDirection row
            , width (pct 25)
            ]
        ]


textDiv : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
textDiv =
    HtmlStyled.div
        [ Attributes.css
            [ marginLeft (rem 2)
            , fontFamilies [ "Courier New" ]
            , fontSize (rem 1.2)
            , width (pct 85)

            -- , color theme.white
            , textAlign left
            ]
        ]


itemDiv : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
itemDiv =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , color theme.black
            , backgroundColor theme.transparentWhite
            , margin2 (rem 1) (rem 0)
            , padding (rem 1)
            , position relative
            , borderRadius (rem 1)
            ]
        ]


itemsWrapper : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
itemsWrapper =
    HtmlStyled.div
        [ Attributes.css
            [ displayFlex
            , marginTop (rem 4.5)
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



--- TOASTS ---


toastStyles : Toast.Info Toast -> List (Html.Attribute msg)
toastStyles toast =
    let
        background : Html.Attribute msg
        background =
            case toast.content.color of
                RedToast ->
                    Html.Attributes.style "background" "#da3125"

                GreenToast ->
                    Html.Attributes.style "background" "#1f9724"

                DarkToast ->
                    Html.Attributes.style "background" "#000000"
    in
    [ background
    , Html.Attributes.style "width" "20rem"
    , Html.Attributes.style "text-transform" "uppercase"
    , Html.Attributes.style "font-size" "1rem"
    , Html.Attributes.style "padding" "1rem"
    , Html.Attributes.style "color" "white"
    , Html.Attributes.style "position" "absolute"
    , Html.Attributes.style "margin-left" "auto"
    , Html.Attributes.style "margin-right" "auto"
    , Html.Attributes.style "left" "0"
    , Html.Attributes.style "right" "0"
    , Html.Attributes.class "toast-fade-out"
    ]

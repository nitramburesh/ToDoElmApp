module Main exposing (..)

import Browser
import Html.Styled as HtmlStyled
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Pages.ToDoItemPage as ToDoItemPage
import Styled
import ToDoItems as Items



---- MODEL ----


type Model
    = Ready String Page
    | FlagsError


type Page
    = ToDoItemPage ToDoItemPage.Model


type alias RawFlags =
    Encode.Value


type alias Flags =
    { baseApiUrl : String
    , toDoItems : List Items.ToDoItem
    }



---- UPDATE ----


type Msg
    = ToDoItemPageMsg ToDoItemPage.Msg


init : RawFlags -> ( Model, Cmd Msg )
init rawFlags =
    case Decode.decodeValue decodeFlags rawFlags of
        Ok { baseApiUrl, toDoItems } ->
            let
                ( toDoItemPageModel, toDoItemPageCmd ) =
                    ToDoItemPage.init toDoItems

                page =
                    ToDoItemPage toDoItemPageModel
            in
            ( Ready baseApiUrl page
            , Cmd.map ToDoItemPageMsg toDoItemPageCmd
            )

        Err _ ->
            ( FlagsError
            , Cmd.none
            )


decodeFlags : Decode.Decoder Flags
decodeFlags =
    Decode.succeed Flags
        |> Pipeline.required "baseApiUrl" Decode.string
        |> Pipeline.optional "toDoItems" Items.decodeToDoItems Items.initialToDoItems


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Ready baseApiUrl page ->
            let
                ( updatedPage, pageCmd ) =
                    pageUpdate msg baseApiUrl page
            in
            ( Ready baseApiUrl updatedPage
            , pageCmd
            )

        FlagsError ->
            ( model
            , Cmd.none
            )


pageUpdate : Msg -> String -> Page -> ( Page, Cmd Msg )
pageUpdate msg baseApiUrl page =
    case ( page, msg ) of
        ( ToDoItemPage subModel, ToDoItemPageMsg subMsg ) ->
            let
                ( updatedPageModel, pageCmd ) =
                    ToDoItemPage.update subMsg subModel baseApiUrl
            in
            ( ToDoItemPage updatedPageModel
            , Cmd.map ToDoItemPageMsg pageCmd
            )



---- VIEW ----


pageView : Page -> HtmlStyled.Html Msg
pageView page =
    case page of
        ToDoItemPage pageModel ->
            ToDoItemPage.view pageModel
                |> HtmlStyled.map ToDoItemPageMsg


view : Model -> HtmlStyled.Html Msg
view model =
    case model of
        Ready _ page ->
            HtmlStyled.div []
                [ Styled.wrapper
                    [ HtmlStyled.button [] [ HtmlStyled.text "Home" ]
                    , HtmlStyled.button [] [ HtmlStyled.text "Page 1" ]
                    , HtmlStyled.button [] [ HtmlStyled.text "Page 2" ]
                    ]
                , pageView page
                ]

        FlagsError ->
            HtmlStyled.text "Something went wrong - flags error..."



---- PROGRAM ----


main : Program RawFlags Model Msg
main =
    Browser.element
        { view = view >> HtmlStyled.toUnstyled
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }

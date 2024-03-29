module Taco exposing (Msg(..), Taco, getApi, getAppWidth, getKey, getShowingLanguageButtons, getTime, getTranslations, getZone, init, update, updateTranslations)

import Api
import Browser.Navigation as Nav
import Time
import Translations


type Taco
    = Taco TacoPayload


type alias TacoPayload =
    { translations : Translations.Model
    , api : Api.Api
    , key : Nav.Key
    , showingLanguageButtons : Bool
    , currentTime : Time.Posix
    , timeZone : Time.Zone
    , appWidth : Int
    }


type Msg
    = NoUpdate
    | SetAccessToken String
    | UpdatedLanguage Translations.Language
    | UpdatedApi Api.Api
    | UpdatedShowingTranslationsButton Bool
    | UpdatedTime Time.Posix
    | UpdatedZone Time.Zone
    | UpdatedAppWidth Int Int



--- INIT ---


init : Translations.Model -> Api.Api -> Nav.Key -> Time.Posix -> Time.Zone -> Int -> Taco
init translations api key currentTime timeZone appWidth =
    Taco
        { translations = translations
        , api = api
        , key = key
        , showingLanguageButtons = False
        , currentTime = currentTime
        , timeZone = timeZone
        , appWidth = appWidth
        }



--- UPDATE MESSAGES ---


update : Msg -> Taco -> Taco
update msg (Taco sharedStatePayload) =
    case msg of
        NoUpdate ->
            Taco sharedStatePayload

        SetAccessToken accessToken ->
            let
                updatedApi =
                    Api.setAccessToken accessToken sharedStatePayload.api

                updatedTacoPayload =
                    { sharedStatePayload | api = updatedApi }
            in
            Taco updatedTacoPayload

        UpdatedLanguage language ->
            let
                updatedTranslations =
                    Translations.changeLanguage language sharedStatePayload.translations

                updatedTacoPayload =
                    { sharedStatePayload | translations = updatedTranslations, showingLanguageButtons = False }
            in
            Taco updatedTacoPayload

        UpdatedApi api ->
            let
                updatedTacoPayload =
                    { sharedStatePayload | api = api }
            in
            Taco updatedTacoPayload

        UpdatedShowingTranslationsButton showingLanguageButtons ->
            let
                updatedTacoPayload =
                    { sharedStatePayload | showingLanguageButtons = not showingLanguageButtons }
            in
            Taco updatedTacoPayload

        UpdatedTime currentTime ->
            let
                updatedTacoPayload =
                    { sharedStatePayload | currentTime = currentTime }
            in
            Taco updatedTacoPayload

        UpdatedZone timeZone ->
            let
                updatedTacoPayload =
                    { sharedStatePayload | timeZone = timeZone }
            in
            Taco updatedTacoPayload

        UpdatedAppWidth width _ ->
            let
                updatedTacoPayload =
                    { sharedStatePayload | appWidth = width }
            in
            Taco updatedTacoPayload



--- GETTERS ---


getKey : Taco -> Nav.Key
getKey (Taco { key }) =
    key


getApi : Taco -> Api.Api
getApi (Taco { api }) =
    api


getTranslations : Taco -> Translations.Model
getTranslations (Taco { translations }) =
    translations


getShowingLanguageButtons : Taco -> Bool
getShowingLanguageButtons (Taco { showingLanguageButtons }) =
    showingLanguageButtons


getTime : Taco -> Time.Posix
getTime (Taco { currentTime }) =
    currentTime


getZone : Taco -> Time.Zone
getZone (Taco { timeZone }) =
    timeZone


getAppWidth : Taco -> Int
getAppWidth (Taco { appWidth }) =
    appWidth



--- SETTERS ---


updateTranslations : Taco -> Translations.Model -> Taco
updateTranslations (Taco sharedState) translations =
    Taco { sharedState | translations = translations }

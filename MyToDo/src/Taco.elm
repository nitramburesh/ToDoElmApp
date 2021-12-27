module Taco exposing (Msg(..), Taco, getApi, getKey, getShowingLanguageButtons, getTranslations, init, update, updateApi, updateLanguageButtons, updateTranslations, updateTime, getTime)

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
    }


type Msg
    = NoUpdate
    | SetAccessToken String
    | UpdatedTranslations Translations.Model
    | UpdatedApi Api.Api
    | UpdatedShowingTranslationsButton Bool
    | UpdatedTime Time.Posix



-- change language


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

        UpdatedTranslations translations ->
            let
                updatedTacoPayload =
                    { sharedStatePayload | translations = translations, showingLanguageButtons = not (getShowingLanguageButtons (Taco sharedStatePayload)) }
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
                    {sharedStatePayload | showingLanguageButtons = not showingLanguageButtons}
            in    
                Taco updatedTacoPayload

        UpdatedTime currentTime ->
            let 
                updatedTacoPayload = 
                    {sharedStatePayload | currentTime = currentTime}
            in
                Taco updatedTacoPayload
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


init : Translations.Model -> Api.Api -> Nav.Key -> Time.Posix -> Taco
init translations api key currentTime =
    Taco
        { translations = translations
        , api = api
        , key = key
        , showingLanguageButtons = False
        , currentTime = currentTime
        }



getTime : Taco -> Time.Posix
getTime (Taco { currentTime }) =
    currentTime

updateTime : Taco -> Time.Posix -> Taco
updateTime (Taco sharedState) time =
    Taco { sharedState | currentTime = time }


updateTranslations : Taco -> Translations.Model -> Taco
updateTranslations (Taco sharedState) translations =
    Taco { sharedState | translations = translations }


updateApi : Taco -> Api.Api -> Taco
updateApi (Taco sharedState) api =
    Taco { sharedState | api = api }


updateLanguageButtons : Taco -> Bool -> Taco
updateLanguageButtons (Taco sharedState) showingLanguageButtons =
    Taco { sharedState | showingLanguageButtons = showingLanguageButtons }

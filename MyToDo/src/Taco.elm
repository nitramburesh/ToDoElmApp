module Taco exposing (Msg(..), Taco, getApi, getKey, getTranslations, init, update, updateApi, updateTranslations)

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
    }


type Msg
    = NoUpdate
    | SetAccessToken String
    | UpdatedTranslations Translations.Model
    | UpdatedApi Api.Api



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
                    { sharedStatePayload | translations = translations }
            in
            Taco updatedTacoPayload 

        UpdatedApi api -> 
            let
                updatedTacoPayload =
                    {sharedStatePayload | api = api}
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


init : Translations.Model -> Api.Api -> Nav.Key -> Taco
init translations api key =
    Taco
        { translations = translations
        , api = api
        , key = key
        }



-- getTime : Taco -> Time.Posix
-- getTime (Taco { currentTime }) =
--     currentTime
-- updateTime : Taco -> Time.Posix -> Taco
-- updateTime (Taco sharedState) time =
--     Taco { sharedState | currentTime = time }


updateTranslations : Taco -> Translations.Model -> Taco
updateTranslations (Taco sharedState) translations =
    Taco { sharedState | translations = translations }


updateApi : Taco -> Api.Api -> Taco
updateApi (Taco sharedState) api =
    Taco { sharedState | api = api }

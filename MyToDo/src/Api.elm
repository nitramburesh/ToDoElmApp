module Api exposing (Api, get, init, setAccessToken)

import Http
import Json.Decode as Decode
import RemoteData


type Api
    = Api (ApiPayload {})


type alias ApiPayload r =
    { r
        | baseApiUrl : String
        , accessToken : String
    }


init : ApiPayload r -> Api
init { baseApiUrl, accessToken } =
    let
        initialPayload =
            { baseApiUrl = baseApiUrl, accessToken = accessToken }
    in
    Api initialPayload


setAccessToken : String -> Api -> Api
setAccessToken token (Api { baseApiUrl, accessToken }) =
    let
        updatedPayload =
            { baseApiUrl = baseApiUrl, accessToken = token }
    in
    Api updatedPayload


get : Decode.Decoder a -> (RemoteData.WebData a -> msg) -> String -> Api -> Cmd msg
get decoder msg endpointSuffix (Api { baseApiUrl, accessToken }) =
    Http.request
        { method = "GET"
        , headers = [ Http.header "x-customToken" accessToken ]
        , url = baseApiUrl ++ endpointSuffix
        , body = Http.emptyBody
        , expect = Http.expectJson (\response -> response |> RemoteData.fromResult |> msg) decoder
        , timeout = Nothing
        , tracker = Nothing
        }

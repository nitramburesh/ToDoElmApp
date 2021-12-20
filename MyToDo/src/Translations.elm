module Translations exposing (Language(..), Model, changeLanguage, decode, translators)

import I18Next
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


type alias Translators =
    { t : String -> String
    , tr : String -> I18Next.Replacements -> String
    }


type Model
    = Model ModelPayload


type alias ModelPayload =
    { allTranslations : AllTranslations
    , selectedLanguage : Language
    }


type alias AllTranslations =
    { en : I18Next.Translations
    , ru : I18Next.Translations
    }


type Language
    = En
    | Ru


decode : Decode.Decoder Model
decode =
    Decode.succeed AllTranslations
        |> Pipeline.required "en" I18Next.translationsDecoder
        |> Pipeline.required "ru" I18Next.translationsDecoder
        |> Decode.map
            (\allTranslations ->
                Model
                    { allTranslations = allTranslations
                    , selectedLanguage = En
                    }
            )


translators : Model -> Translators
translators (Model modelPayload) =
    let
        translations =
            translationsForLanguage modelPayload
    in
    { t = I18Next.t translations
    , tr = I18Next.tr translations I18Next.Curly
    }


changeLanguage : Language -> Model -> Model
changeLanguage language (Model modelPayload) =
    let
        updatedModelPayload =
            { modelPayload | selectedLanguage = language }
    in
    Model updatedModelPayload


translationsForLanguage : ModelPayload -> I18Next.Translations
translationsForLanguage { allTranslations, selectedLanguage } =
    case selectedLanguage of
        En ->
            allTranslations.en

        Ru ->
            allTranslations.ru

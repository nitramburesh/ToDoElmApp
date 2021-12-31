module Router exposing (ExternalRoute(..), Route(..), externalRouteToString, href, parseUrl, redirect, routeToString, toExternalRoute)

import Browser
import Browser.Navigation as Nav
import Html.Styled as HtmlStyled
import Html.Styled.Attributes as Attr
import Taco
import Url
import Url.Parser as Parser


type Route
    = ToDoItemRoute
    | NextPageRoute


type ExternalRoute
    = SeznamRoute
    | YoutubeRoute
    | GoogleRoute
    | RedditRoute


parseUrl : Url.Url -> Maybe Route
parseUrl url =
    url
        |> Parser.parse parser


parser : Parser.Parser (Route -> Route) Route
parser =
    Parser.oneOf
        [ Parser.map ToDoItemRoute Parser.top
        , Parser.map ToDoItemRoute (Parser.s "todoitempage")
        , Parser.map NextPageRoute (Parser.s "nextpage")
        ]


redirect : Taco.Taco -> Route -> Cmd msg
redirect sharedState route =
    let
        routeString =
            routeToString route
    in
    Nav.replaceUrl (Taco.getKey sharedState) routeString


href : Route -> HtmlStyled.Attribute msg
href route =
    Attr.href (routeToString route)


routeToString : Route -> String
routeToString route =
    case route of
        ToDoItemRoute ->
            "todoitempage"

        NextPageRoute ->
            "nextpage"


externalRouteToString : ExternalRoute -> String
externalRouteToString route =
    case route of
        SeznamRoute ->
            "https://www.seznam.cz/"

        YoutubeRoute ->
            "https://www.youtube.com/"

        GoogleRoute ->
            "https://www.google.com/"

        RedditRoute ->
            "https://www.reddit.com/"


toExternalRoute : ExternalRoute -> Browser.UrlRequest
toExternalRoute externalRoute =
    let
        route =
            externalRouteToString externalRoute
    in
    Browser.External route

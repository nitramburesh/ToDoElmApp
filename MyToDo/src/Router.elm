module Router exposing (Route(..), parseUrl, routeToString)

import Url
import Url.Parser as Parser


type Route
    = ToDoItemRoute
    | NextPageRoute


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


routeToString : Route -> String
routeToString route =
    case route of
        ToDoItemRoute ->
            "todoitempage"

        NextPageRoute ->
            "nextpage"

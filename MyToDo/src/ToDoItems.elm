port module ToDoItems exposing (ToDoItem, decodeToDoItem, decodeToDoItems, encodeToDoItems, filterItems, initialToDoItems, storeItems)

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode


port storeItems : Encode.Value -> Cmd msg


type alias ToDoItem =
    { id : Int
    , title : String
    , completed : Bool
    }


initialToDoItems : List ToDoItem
initialToDoItems =
    []


decodeToDoItem : Decode.Decoder ToDoItem
decodeToDoItem =
    Decode.succeed ToDoItem
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "completed" Decode.bool


decodeToDoItems : Decode.Decoder (List ToDoItem)
decodeToDoItems =
    Decode.list decodeToDoItem


encodeToDoItems : List ToDoItem -> Encode.Value
encodeToDoItems =
    Encode.list
        (\item ->
            Encode.object
                [ ( "id", Encode.int item.id )
                , ( "title", Encode.string item.title )
                , ( "completed", Encode.bool item.completed )
                ]
        )



-- List.filter (.id >> (==) id)


filterItems : String -> List ToDoItem -> List ToDoItem
filterItems textInput =
    List.filter (\item -> String.contains (String.toLower textInput) (String.toLower item.title))

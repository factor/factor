! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: json.reader

HELP: json>
{ $values { "string" "a string in JSON format" } { "object" "a deserialized object" } }
{ $description "Deserializes the JSON formatted string into a Factor object. JSON objects are converted to Factor hashtables. All other JSON objects convert to their obvious Factor equivalents." } ;

HELP: read-json
{ $values { "objects" { $sequence "deserialized objects" } } }
{ $description "Reads JSON formatted strings into a vector of Factor object until the end of the stream is reached. JSON objects are converted to Factor hashtables. All other JSON objects convert to their obvious Factor equivalents." } ;

HELP: path>json
{ $values
    { "path" "a pathname string" }
    { "json" "a JSON object" }
}
{ $description "Reads a file into a single JSON object. Throws an error if the file contains more than one json." } ;
{ path>json path>jsons } related-words

HELP: path>jsons
{ $values
    { "path" "a pathname string" }
    { "jsons" { $sequence "JSON objects" } }
}
{ $description "Reads a file into a sequence of JSON objects and returns them all." } ;

ARTICLE: "json.reader" "JSON reader"
"The " { $vocab-link "json.reader" } " vocabulary defines a word for parsing strings in JSON format."
"For more information, see " { $url "https://en.wikipedia.org/wiki/JSON" } "."
{ $subsections json> read-json path>json path>jsons } ;

ABOUT: "json.reader"

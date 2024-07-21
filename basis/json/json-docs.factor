USING: help.markup help.syntax kernel ;
IN: json

HELP: json>
{ $values { "string" "a string in JSON format" } { "object" "a deserialized object" } }
{ $description "Deserializes the JSON formatted string into a Factor object. JSON objects are converted to Factor hashtables. All other JSON objects convert to their obvious Factor equivalents." }
{ $notes "The full name of this word could be " { $snippet "json-string>object" } "." } ;

HELP: read-json
{ $values { "object" "deserialized object" } }
{ $description "Reads a JSON formatted strings into a Factor object. JSON objects are converted to Factor hashtables. All other JSON objects convert to their obvious Factor equivalents." } ;

HELP: read-jsons
{ $values { "objects" { $sequence "deserialized objects" } } }
{ $description "Reads JSON formatted strings into a vector of Factor object until the end of the stream is reached. JSON objects are converted to Factor hashtables. All other JSON objects convert to their obvious Factor equivalents." } ;

{ >json json> read-json read-jsons write-json } related-words

HELP: path>json
{ $values
    { "path" "a pathname string" }
    { "json" "a JSON object" }
}
{ $description "Reads a file into a single JSON object. Throws an error if the file contains more than one json." } ;

{ path>json path>jsons json>path jsons>path } related-words

HELP: path>jsons
{ $values
    { "path" "a pathname string" }
    { "jsons" { $sequence "JSON objects" } }
}
{ $description "Reads a file into a sequence of JSON objects and returns them all." } ;

HELP: >json
{ $values { "obj" object } { "string" "the object converted to JSON format" } }
{ $description "Serializes the object into a JSON formatted string." }
{ $notes "The full name of this word could be " { $snippet "object>json-string" } "." } ;

HELP: write-json
{ $values { "obj" object } }
{ $description "Serializes the object into a JSON formatted string and outputs it to the standard output stream."
$nl
"Some options can control the formatting of the result:"
{ $table
    { { $link json-allow-fp-special? } "Allow special floating-points: NaN, Infinity, -Infinity" }
    { { $link json-friendly-keys? }    { "Convert " { $snippet "-" } " to " { $snippet "_" } " in tuple slots and hashtable keys" } }
    { { $link json-coerce-keys? }      "Coerce hashtable keys into strings" }
    { { $link json-escape-slashes? }   "Escape forward slashes inside strings" }
    { { $link json-escape-unicode? }   "Escape unicode values inside strings" }
}
}
{ $see-also >json } ;

{ json-fp-special-error json-allow-fp-special? } related-words

HELP: json-fp-special-error
{ $error-description "Thrown by " { $link "json" } " when attempting to serialize -1/0. or +1/0. or NaN when " { $link json-allow-fp-special? } " is not enabled." } ;

ARTICLE: "json" "JSON serialization"
"The " { $vocab-link "json" } " vocabulary defines words for working with JSON (JavaScript Object Notation) formats."
$nl
"Parsing strings in JSON format:"
{ $subsections
    json>
    read-json
    read-jsons
    path>json
    path>jsons
}
"Converting objects to JSON format:"
{ $subsections
    >json
    write-json
}
"Working with JSON null values:"
{ $subsections
    json-null?
    if-json-null
    when-json-null
    unless-json-null
}
"Working with JSON Lines format:"
{ $subsections
    jsonlines>
    read-jsonlines
    >jsonlines
    write-jsonlines
}
"For more information, see " { $url "https://en.wikipedia.org/wiki/JSON" } "." ;

ABOUT: "json"

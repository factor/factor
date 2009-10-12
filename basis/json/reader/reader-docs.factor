! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: json.reader

HELP: json>
{ $values { "string" "a string in JSON format" } { "object" "a deserialized object" } }
{ $description "Deserializes the JSON formatted string into a Factor object. JSON objects are converted to Factor hashtables. All other JSON objects convert to their obvious Factor equivalents." } ;

ARTICLE: "json.reader" "JSON reader"
"The " { $vocab-link "json.reader" } " vocabulary defines a word for parsing strings in JSON format."
{ $subsections json> } ;

ABOUT: "json.reader"

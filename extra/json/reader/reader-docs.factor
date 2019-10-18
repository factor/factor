! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax json.reader ;

HELP: json> "( string -- object )"
{ $values { "string" "a string in JSON format" } { "object" "yhe object deserialized from the JSON string" } }
{ $description "Deserializes the JSON formatted string into a Factor object. JSON objects are converted to Factor hashtables. All other JSON objects convert to their obvious Factor equivalents." } ;
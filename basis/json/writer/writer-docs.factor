! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: json help.markup help.syntax kernel ;
IN: json.writer

HELP: >json
{ $values { "obj" object } { "string" "the object converted to JSON format" } }
{ $description "Serializes the object into a JSON formatted string." }
{ $see-also json-print } ;

HELP: json-print
{ $values { "obj" object } }
{ $description "Serializes the object into a JSON formatted string and outputs it to the standard output stream."
$nl
"Some options can control the formatting of the result:"
{ $table
     { { $link json-allow-fp-special? } "Allow special floating-points: NaN, Infinity, -Infinity" }
     { { $link json-friendly-keys? }    "Convert - to _ in tuple slots and hashtable keys" }
     { { $link json-coerce-keys? }      "Coerce hashtable keys into strings" }
     { { $link json-escape-slashes? }   "Escape forward slashes inside strings" }
     { { $link json-escape-unicode? }   "Escape unicode values inside strings" }
}
}
{ $see-also >json } ;

{ json-fp-special-error json-allow-fp-special? } related-words

HELP: json-fp-special-error
{ $error-description "Thrown by " { $link "json.writer" } " when attempting to serialize -1/0. or +1/0. or NaN when " { $link json-allow-fp-special? } " is not enabled." } ;

ARTICLE: "json.writer" "JSON writer"
"The " { $vocab-link "json.writer" } " vocabulary defines words for converting objects to JSON format."
{ $subsections
    >json
    json-print
} ;

ABOUT: "json.writer"

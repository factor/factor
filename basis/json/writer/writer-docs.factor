! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: json.writer

HELP: >json
{ $values { "obj" object } { "string" "the object converted to JSON format" } }
{ $description "Serializes the object into a JSON formatted string." } 
{ $see-also json-print } ;

HELP: json-print
{ $values { "obj" object } }
{ $description "Serializes the object into a JSON formatted string and outputs it to the standard output stream. 

By default, tuples and hashtables are serialized into Javascript-friendly JSON formatted output by converting keys containing dashes into underscores. This behaviour can be modified by setting the dynamic variable " { $strong "jsvar-encode?" } " to false." } 
{ $see-also >json } ;

ARTICLE: "json.writer" "JSON writer"
"The " { $vocab-link "json.writer" } " vocabulary defines words for converting objects to JSON format."
{ $subsections
    >json
    json-print
} ;

ABOUT: "json.writer"

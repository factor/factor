! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax json.writer ;

HELP: >json "( obj -- string )"
{ $values { "obj" "an object" } { "string" "the object converted to JSON format" } }
{ $description "Serializes the object into a JSON formatted string." } 
{ $see-also json-print } ;

HELP: json-print "( obj -- )"
{ $values { "obj" "an object" } }
{ $description "Serializes the object into a JSON formatted string and outputs it to the standard output stream." } 
{ $see-also >json } ;


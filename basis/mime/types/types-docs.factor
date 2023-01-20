! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax sequences ;
IN: mime.types

HELP: mime-db
{ $values

    { "seq" sequence } }
{ $description "Outputs an array where the first element is a MIME type and the rest of the array is file extensions that have that MIME type." } ;

HELP: mime-type
{ $values
    { "filename" "a filename" }
    { "mime-type" "a MIME type string" } }
{ $description "Outputs the MIME type associated with a path by parsing the path's file extension and looking it up in the table returned by " { $link mime-types } "." } ;

HELP: mime-types
{ $values

    { "assoc" assoc } }
{ $description "Outputs an " { $snippet "assoc" } " made from the data in the " { $link mime-db } " word where the keys are file extensions and the values are the corresponding MIME types." } ;

HELP: nonstandard-mime-types
{ $values

    { "assoc" assoc } }
{ $description "A list of Factor-specific MIME types that are added to the MIME database loaded from disk." } ;

ARTICLE: "mime.types" "MIME types"
"The " { $vocab-link "mime.types" } " vocabulary loads a file of MIME types and provides a word to look up the MIME type based on a file extension." $nl
"Looking up a MIME type:"
{ $subsections mime-type } ;

ABOUT: "mime.types"

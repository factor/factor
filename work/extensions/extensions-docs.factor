! Copyright (C) 2013 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: extensions

IN: sequences
HELP: unique-filter
{ $values { "seq" "value" } { "quot" "quotation" } }
{ $description "Given a sequence containing elements which be used as keys will return the elements unique to the sequence by appling the quot to each element which is used to extract a value used as a key." }
{ $examples
  { $code 
    "USING: sequences ;" "{ { 1 \"one\" } { 2 \"two\" } { 1 \"one\"} { 2 \"two\" } { 3 \"three\" } } [ second ] unique-filter" 
    }
}
{ $notes "No Notes" }
;

ARTICLE: "extensions" "Factor extensions"
{ $vocab-link "extensions" }
$nl
"Contains extensions to existing vocabularies in the Factor folder which have not yet been incorporated into the master branch. This permits adding to existing vocabularies without cluttering the current commit or to add to vocabularies personal preferences"
;

ABOUT: "extensions"

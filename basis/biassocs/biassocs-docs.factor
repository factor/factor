IN: biassocs
USING: help.markup help.syntax assocs kernel ;

HELP: biassoc
{ $class-description "The class of bidirectional assocs. Bidirectional assoc are implemented by combining two assocs, with one the transpose of the other." } ;

HELP: <biassoc>
{ $values { "exemplar" assoc } { "biassoc" biassoc } }
{ $description "Creates a new biassoc using a new assoc of the same type as " { $snippet "exemplar" } " for underlying storage." } ;

HELP: <bihash>
{ $values { "biassoc" biassoc } }
{ $description "Creates a new biassoc using a pair of hashtables for underlying storage." } ;

HELP: set-at-once
{ $values { "value" object } { "key" object } { "assoc" assoc } }
{ $description "If the assoc does not contain the given key, adds the key/value pair to the assoc, otherwise does nothing." } ;

HELP: >biassoc
{ $values { "assoc" assoc } { "biassoc" biassoc } }
{ $description "Constructs a new biassoc with the same key/value pairs as the given assoc." } ;

ARTICLE: "biassocs" "Bidirectional assocs"
"A " { $emphasis "bidirectional assoc" } " combines a pair of assocs to form a data structure where both normal assoc operations (eg, " { $link at } "), as well as " { $link "assocs-values" } " (eg, " { $link value-at } ") run in sub-linear time."
$nl
"Bidirectional assocs implement the entire " { $link "assocs-protocol" } " with the exception of " { $link delete-at } ". Duplicate values are allowed, however value lookups with " { $link value-at } " only return the first key that a given value was stored with."
$nl
"The class of biassocs:"
{ $subsections
    biassoc
    biassoc?
}
"Creating new biassocs:"
{ $subsections
    <biassoc>
    <bihash>
}
"Converting existing assocs to biassocs:"
{ $subsections >biassoc } ;

ABOUT: "biassocs"

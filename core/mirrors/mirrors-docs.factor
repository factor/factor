USING: help.markup help.syntax slots kernel assocs sequences ;
IN: mirrors

ARTICLE: "mirrors" "Mirrors"
"A reflective view of an object's slots and their values:"
{ $subsection mirror }
{ $subsection <mirror> }
"A view of a sequence as an associative structure:"
{ $subsection enum }
{ $subsection <enum> }
"Utility word used by developer tools which inspect objects:"
{ $subsection make-mirror } ;

ABOUT: "mirrors"

HELP: object-slots
{ $values { "obj" object } { "seq" "a sequence of " { $link slot-spec } " instances" } }
{ $description "Outputs a sequence of slot specifiers for the object." } ;

HELP: mirror
{ $class-description "An associative structure which wraps an object and presents itself as a mapping from slot names to the object's slot values. Mirrors are used to build reflective developer tools."
$nl
"Mirrors are mutable, however new keys cannot be inserted and keys cannot be deleted, only values of existing keys can be changed."
$nl
"Mirrors are created by calling " { $link <mirror> } " or " { $link make-mirror } "." } ;

HELP: <mirror>
{ $values { "object" object } { "mirror" mirror } } 
{ $description "Creates a " { $link mirror } " reflecting an object." }
{ $examples
    { $example
        "USING: assocs mirrors ;"
        "TUPLE: circle center radius ;"
        "C: <circle> circle"
        "{ 100 50 } 15 <circle> <mirror> >alist ."
        "{ { circle-center { 100 50 } } { circle-radius 15 } }"
    }
} ;

HELP: >mirror<
{ $values { "mirror" mirror } { "obj" object } { "slots" "a sequence of " { $link slot-spec } " instances" } }
{ $description "Pushes the object being viewed in the mirror together with its slots." } ;

HELP: enum
{ $class-description "An associative structure which wraps a sequence and maps integers to the corresponding elements of the sequence."
$nl
"Enumerations are mutable; note that deleting a key calls " { $link delete-nth } ", which results in all subsequent elements being shifted down." } ;

HELP: make-mirror
{ $values { "obj" object } { "assoc" "an assoc" } }
{ $description "Creates an assoc which reflects the internal structure of the object." } ;

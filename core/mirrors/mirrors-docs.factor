USING: help.markup help.syntax slots kernel assocs sequences ;
IN: mirrors

ARTICLE: "mirrors" "Mirrors"
"The " { $vocab-link "mirrors" } " vocabulary defines data types which present an object's slots and slot values as an associative structure. This enables idioms such as iteration over all slots in a tuple, or editing of tuples, sequences and assocs in a generic fashion. This functionality is used by developer tools and meta-programming utilities."
$nl
"A mirror provides such a view of a tuple:"
{ $subsection mirror }
{ $subsection <mirror> }
"An enum provides such a view of a sequence:"
{ $subsection enum }
{ $subsection <enum> }
"Utility word used by developer tools which inspect objects:"
{ $subsection make-mirror }
{ $see-also "slots" } ;

ABOUT: "mirrors"

HELP: object-slots
{ $values { "obj" object } { "seq" "a sequence of " { $link slot-spec } " instances" } }
{ $description "Outputs a sequence of slot specifiers for the object." } ;

HELP: mirror
{ $class-description "An associative structure which wraps an object and presents itself as a mapping from slot names to the object's slot values. Mirrors are used to build reflective developer tools."
$nl
"Mirrors are mutable, however new keys cannot be inserted, only values of existing keys can be changed. Deleting a key has the effect of setting its value to " { $link f } "."
$nl
"Mirrors are created by calling " { $link <mirror> } " or " { $link make-mirror } "." } ;

HELP: <mirror>
{ $values { "object" object } { "mirror" mirror } } 
{ $description "Creates a " { $link mirror } " reflecting an object." }
{ $examples
    { $example
        "USING: assocs mirrors prettyprint ;"
        "TUPLE: circle center radius ;"
        "C: <circle> circle"
        "{ 100 50 } 15 <circle> <mirror> >alist ."
        "{ { \"delegate\" f } { \"center\" { 100 50 } } { \"radius\" 15 } }"
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
{ $values { "obj" object } { "assoc" assoc } }
{ $description "Creates an assoc which reflects the internal structure of the object." } ;

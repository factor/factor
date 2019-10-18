USING: help.markup help.syntax slots kernel assocs sequences ;
IN: mirrors

ARTICLE: "mirrors" "Mirrors"
"The " { $vocab-link "mirrors" } " vocabulary defines data types which present an object's slots and slot values as an associative structure. This enables idioms such as iteration over all slots in a tuple, or editing of tuples, sequences and assocs in a generic fashion. This functionality is used by developer tools and meta-programming utilities."
$nl
"A mirror provides such a view of a tuple:"
{ $subsections
    mirror
    <mirror>
}
"Utility word used by developer tools which inspect objects:"
{ $subsections make-mirror }
{ $see-also "slots" } ;

ABOUT: "mirrors"

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
        "IN: scratchpad"
        "TUPLE: circle center radius ;"
        "C: <circle> circle"
        "{ 100 50 } 15 <circle> <mirror> >alist ."
        "{ { \"center\" { 100 50 } } { \"radius\" 15 } }"
    }
} ;

HELP: make-mirror
{ $values { "obj" object } { "assoc" assoc } }
{ $description "Creates an assoc which reflects the internal structure of the object." } ;

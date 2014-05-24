IN: disjoint-sets
USING: help.markup help.syntax kernel assocs math ;

HELP: <disjoint-set>
{ $values { "disjoint-set" disjoint-set } }
{ $description "Creates a new disjoint set data structure with no elements." } ;

HELP: add-atom
{ $values { "a" object } { "disjoint-set" disjoint-set } }
{ $description "Adds a new element to the disjoint set, initially only equivalent to itself." } ;

HELP: equiv-set-size
{ $values { "a" object } { "disjoint-set" disjoint-set } { "n" integer } }
{ $description "Outputs the number of elements in the equivalence class of " { $snippet "a" } "." } ;

HELP: equiv?
{ $values { "a" object } { "b" object } { "disjoint-set" disjoint-set } { "?" boolean } }
{ $description "Tests if two elements belong to the same equivalence class." } ;

HELP: equate
{ $values { "a" object } { "b" object } { "disjoint-set" disjoint-set } }
{ $description "Merges the equivalence classes of two elements, which must previously have been added with " { $link add-atom } "." } ;

HELP: assoc>disjoint-set
{ $values { "assoc" assoc } { "disjoint-set" disjoint-set } }
{ $description "Given an assoc representation of a graph where the keys are vertices and key/value pairs are edges, creates a disjoint set whose elements are the keys of assoc, and two keys are equivalent if they belong to the same connected component of the graph." }
{ $examples
    { $example
        "USING: disjoint-sets kernel prettyprint ;"
        "H{ { 1 1 } { 2 1 } { 3 4 } { 4 4 } { 5 3 } } assoc>disjoint-set"
        "1 2 pick equiv? ."
        "4 5 pick equiv? ."
        "1 5 pick equiv? ."
        "drop"
        "t\nt\nf"
    }
} ;

ARTICLE: "disjoint-sets" "Disjoint sets"
"The " { $vocab-link "disjoint-sets" } " vocabulary implements the " { $emphasis "disjoint set" } " data structure (also known as " { $emphasis "union-find" } ", after the two main operations which it supports) that represents a set of elements partitioned into disjoint equivalence classes, or alternatively, an equivalence relation on a set."
$nl
"The two main supported operations are equating two elements, which joins their equivalence classes, and checking if two elements belong to the same equivalence class. Both operations have the time complexity of the inverse Ackermann function, which for all intents and purposes is constant time."
$nl
"The class of disjoint sets:"
{ $subsections disjoint-set }
"Creating new disjoint sets:"
{ $subsections
    <disjoint-set>
    assoc>disjoint-set
}
"Queries:"
{ $subsections
    equiv?
    equiv-set-size
}
"Adding elements:"
{ $subsections add-atom }
"Equating elements:"
{ $subsections equate }
"Additionally, disjoint sets implement the " { $link clone } " generic word." ;

ABOUT: "disjoint-sets"

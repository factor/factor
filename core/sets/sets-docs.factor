USING: kernel help.markup help.syntax sequences quotations assocs ;
IN: sets

ARTICLE: "sets" "Set-theoretic operations on sequences"
"Set-theoretic operations on sequences are defined on the " { $vocab-link "sets" } " vocabulary. All of these operations use hashtables internally to achieve linear running time."
$nl
"Remove duplicates:"
{ $subsection prune }
"Test for duplicates:"
{ $subsection all-unique? }
{ $subsection duplicates }
"Set operations on sequences:"
{ $subsection diff }
{ $subsection intersect }
{ $subsection union }
"Set-theoretic predicates:"
{ $subsection intersects? }
{ $subsection subset? }
{ $subsection set= }
"A word used to implement the above:"
{ $subsection unique }
"Adding elements to sets:"
{ $subsection adjoin }
{ $subsection conjoin }
{ $see-also member? memq? any? all? "assocs-sets" } ;

ABOUT: "sets"

HELP: adjoin
{ $values { "elt" object } { "seq" "a resizable mutable sequence" } }
{ $description "Removes all elements equal to " { $snippet "elt" } ", and adds " { $snippet "elt" } " at the end of the sequence." }
{ $examples
    { $example
        "USING: namespaces prettyprint sets ;"
        "V{ \"beans\" \"salsa\" \"cheese\" } \"v\" set"
        "\"nachos\" \"v\" get adjoin"
        "\"salsa\" \"v\" get adjoin"
        "\"v\" get ."
        "V{ \"beans\" \"cheese\" \"nachos\" \"salsa\" }"
    }
}
{ $side-effects "seq" } ;

HELP: conjoin
{ $values { "elt" object } { "assoc" assoc } }
{ $description "Stores a key/value pair, both equal to " { $snippet "elt" } ", into the assoc." }
{ $examples
    { $example
        "USING: kernel prettyprint sets ;"
        "H{ } clone 1 over conjoin ."
        "H{ { 1 1 } }"
    }
}
{ $side-effects "assoc" } ;

HELP: unique
{ $values { "seq" "a sequence" } { "assoc" assoc } }
{ $description "Outputs a new assoc where the keys and values are equal." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 1 2 2 3 3 } unique ." "H{ { 1 1 } { 2 2 } { 3 3 } }" }
} ;

HELP: prune
{ $values { "seq" "a sequence" } { "newseq" "a sequence" } }
{ $description "Outputs a new sequence with each distinct element of " { $snippet "seq" } " appearing only once. Elements are compared for equality using " { $link = } " and elements are ordered according to their position in " { $snippet "seq" } "." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 1 t 3 t } prune ." "V{ 1 t 3 }" }
} ;

HELP: duplicates
{ $values { "seq" "a sequence" } { "newseq" "a sequence" } }
{ $description "Outputs a new sequence consisting of elements which occur more than once in " { $snippet "seq" } "." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 1 2 1 } duplicates ." "{ 1 2 1 }" }
} ;

HELP: all-unique?
{ $values { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests whether a sequence contains any repeated elements." }
{ $example
    "USING: sets prettyprint ;"
    "{ 0 1 1 2 3 5 } all-unique? ."
    "f"
} ;

HELP: diff
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in " { $snippet "seq1" } " but not " { $snippet "seq2" } ", comparing elements for equality." 
} { $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } { 2 3 4 } diff ." "{ 1 }" }
} ;

HELP: intersect
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in both " { $snippet "seq1" } " and " { $snippet "seq2" } "." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } { 2 3 4 } intersect ." "{ 2 3 }" }
} ;

HELP: union
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in " { $snippet "seq1" } " and " { $snippet "seq2" } " which does not contain duplicate values." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } { 2 3 4 } union ." "V{ 1 2 3 4 }" }
} ;

{ diff intersect union } related-words

HELP: intersects?
{ $values { "seq1" sequence } { "seq2" sequence } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "seq1" } " and " { $snippet "seq2" } " have any elements in common." }
{ $notes "If one of the sequences is empty, the result is always " { $link f } "." } ;

HELP: subset?
{ $values { "seq1" sequence } { "seq2" sequence } { "?" "a boolean" } }
{ $description "Tests if every element of " { $snippet "seq1" } " is contained in " { $snippet "seq2" } "." }
{ $notes "If " { $snippet "seq1" } " is empty, the result is always " { $link t } "." } ;

HELP: set=
{ $values { "seq1" sequence } { "seq2" sequence } { "?" "a boolean" } }
{ $description "Tests if both sequences contain the same elements, disregrading order and duplicates." } ;

HELP: gather
{ $values
     { "seq" sequence } { "quot" quotation }
     { "newseq" sequence } }
{ $description "Maps a quotation onto a sequence, concatenates the results of the mapping, and removes duplicates." } ;

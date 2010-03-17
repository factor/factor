USING: assocs hashtables help.markup help.syntax kernel
quotations sequences vectors ;
IN: sets

ARTICLE: "sets" "Sets"
"A set is an unordered list of elements. Words for working with sets are in the " { $vocab-link "sets" } " vocabulary." $nl
"All sets are instances of a mixin class:"
{ $subsections
    set
    set?
}
{ $subsections "set-operations" "set-implementations" } ;

ABOUT: "sets"

ARTICLE: "set-operations" "Operations on sets"
"To test if an object is a member of a set:"
{ $subsections member? }
"All sets can be represented as a sequence, without duplicates, of their members:"
{ $subsections members }
"Sets can have members added or removed destructively:"
{ $subsections
    adjoin
    delete
}
"Basic mathematical operations, which any type of set may override for efficiency:"
{ $subsections
    diff
    intersect
    union
}
"Mathematical predicates on sets, which may be overridden for efficiency:"
{ $subsections
    intersects?
    subset?
    set=
}
"An optional generic word for creating sets of the same class as a given set:"
{ $subsections set-like }
"An optional generic word for creating a set with a fast lookup operation, if the set itself has a slow lookup operation:"
{ $subsections fast-set }
"For set types that allow duplicates, like sequence sets, some additional words test for duplication:"
{ $subsections
    all-unique?
    duplicates
}
"Utilities for sets and sequences:"
{ $subsections
     within
     without
} ;

ARTICLE: "set-implementations" "Set implementations"
"There are several implementations of sets in the Factor library. More can be added if they implement the words of the set protocol, the basic set operations."
{ $subsections
    "sequence-sets"
    "hash-sets"
    "bit-sets"
} ;

ARTICLE: "sequence-sets" "Sequences as sets"
"Any sequence can be used as a set. The members of this set are the elements of the sequence. Calling the word " { $link members } " on a sequence returns a copy of the sequence with only one listing of each member. Destructive operations " { $link adjoin } " and " { $link delete } " only work properly on growable sequences like " { $link vector } "s."
$nl
"Care must be taken in writing efficient code using sequence sets. Testing for membership with " { $link in? } ", as well as the destructive set operations, take time proportional to the size of the sequence. Another representation, like " { $link "hash-sets" } ", would take constant time for membership tests. But binary operations like " { $link union } "are asymptotically optimal, taking time proportional to the sum of the size of the inputs."
$nl
"As one particlar example, " { $link POSTPONE: f } " is a representation of the empty set, as it represents the empty sequence." ;

HELP: set
{ $class-description "The class of all sets. Custom implementations of the set protocol should be declared as instances of this mixin for all set implementation to work correctly." } ;

HELP: adjoin
{ $values { "elt" object } { "set" set } }
{ $description "Destructively adds " { $snippet "elt" } " to " { $snippet "set" } ". For sequences, this guarantees that this element is not duplicated, and that it is at the end of the sequence." $nl "Each mutable set type is expected to implement a method on this generic word." }
{ $examples
    { $example
        "USING: prettyprint sets kernel ;"
        "V{ \"beans\" \"salsa\" \"cheese\" } clone"
        "\"nachos\" over adjoin"
        "\"salsa\" over adjoin"
        "."
        "V{ \"beans\" \"cheese\" \"nachos\" \"salsa\" }"
    }
}
{ $side-effects "set" } ;

HELP: delete
{ $values { "elt" object } { "set" set } }
{ $description "Destructively removes " { $snippet "elt" } " from " { $snippet "set" } ". If the element is not present, this does nothing." $nl "Each mutable set type is expected to implement a method on this generic word." }
{ $side-effects "set" } ;

HELP: members
{ $values { "set" set } { "seq" sequence } }
{ $description "Creates a sequence with a single copy of each member of the set." $nl "Each set type is expected to implement a method on this generic word." } ;

HELP: in?
{ $values { "elt" object } { "set" set } { "?" "a boolean" } }
{ $description "Tests whether the element is a member of the set." $nl "Each set type is expected to implement a method on this generic word as part of the set protocol." } ;

HELP: adjoin-at
{ $values { "value" object } { "key" object } { "assoc" assoc } }
{ $description "Adds " { $snippet "value" } " to the set stored at " { $snippet "key" } " of " { $snippet "assoc" } "." }
{ $side-effects "assoc" } ;

HELP: duplicates
{ $values { "set" set } { "seq" sequence } }
{ $description "Outputs a sequence consisting of elements which occur more than once in " { $snippet "set" } "." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 1 2 1 } duplicates ." "{ 1 2 1 }" }
} ;

HELP: all-unique?
{ $values { "set" set } { "?" "a boolean" } }
{ $description "Tests whether a set contains any repeated elements." }
{ $example
    "USING: sets prettyprint ;"
    "{ 0 1 1 2 3 5 } all-unique? ."
    "f"
} ;

HELP: diff
{ $values { "set1" set } { "set2" set } { "set" set } }
{ $description "Outputs a set consisting of elements present in " { $snippet "set1" } " but not " { $snippet "set2" } ", comparing elements for equality." 
"This word has a default definition which works for all sets, but set implementations may override the default for efficiency."
} { $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } { 2 3 4 } diff ." "{ 1 }" }
} ;

HELP: intersect
{ $values { "set1" set } { "set2" set } { "set" set } }
{ $description "Outputs a set consisting of elements present in both " { $snippet "set1" } " and " { $snippet "set2" } "."
"This word has a default definition which works for all sets, but set implementations may override the default for efficiency." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } { 2 3 4 } intersect ." "{ 2 3 }" }
} ;

HELP: union
{ $values { "set1" set } { "set2" set } { "set" set } }
{ $description "Outputs a set consisting of elements present in either " { $snippet "set1" } " or " { $snippet "set2" } " which does not contain duplicate values."
"This word has a default definition which works for all sets, but set implementations may override the default for efficiency." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } { 2 3 4 } union ." "{ 1 2 3 4 }" }
} ;

{ diff intersect union } related-words

HELP: intersects?
{ $values { "set1" set } { "set2" set } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "set1" } " and " { $snippet "set2" } " have any elements in common." }
{ $notes "If one of the sets is empty, the result is always " { $link f } "." } ;

HELP: subset?
{ $values { "set1" set } { "set2" set } { "?" "a boolean" } }
{ $description "Tests if every element of " { $snippet "set1" } " is contained in " { $snippet "set2" } "." }
{ $notes "If " { $snippet "set1" } " is empty, the result is always " { $link t } "." } ;

HELP: set=
{ $values { "set1" set } { "set2" set } { "?" "a boolean" } }
{ $description "Tests if both sets contain the same elements, disregrading order and duplicates." } ;

HELP: gather
{ $values
     { "seq" sequence } { "quot" quotation }
     { "newseq" sequence } }
{ $description "Maps a quotation onto a sequence, concatenates the results of the mapping, and removes duplicates." } ;

HELP: set-like
{ $values { "set" set } { "exemplar" set } { "set'" set } }
{ $description "If the conversion is defined for the exemplar, converts the set into a set of the exemplar's class. This is not guaranteed to create a new set, for example if the input set and exemplar are of the same class." $nl
"Set implementations may optionally implement a method on this generic word. The default implementation returns its input set." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } HS{ } set-like ." "HS{ 1 2 3 }" }
} ;

HELP: within
{ $values { "seq" sequence } { "set" set } { "subseq" sequence } }
{ $description "Returns the subsequence of the given sequence consisting of members of the set. This may contain duplicates, if the sequence has duplicates." } ;

HELP: without
{ $values { "seq" sequence } { "set" set } { "subseq" sequence } }
{ $description "Returns the subsequence of the given sequence consisting of things that are not members of the set. This may contain duplicates, if the sequence has duplicates." } ;

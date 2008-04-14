USING: kernel help.markup help.syntax sequences ;
IN: sets

ARTICLE: "sets" "Set theoretic operations"
"Remove duplicates:"
{ $subsection prune }
"Test for duplicates:"
{ $subsection all-unique? }
"Set operations on sequences:"
{ $subsection diff }
{ $subsection intersect }
{ $subsection union } ;

HELP: unique
{ $values { "seq" "a sequence" } { "assoc" "an assoc" } }
{ $description "Outputs a new assoc where the keys and values are equal." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 1 2 2 3 3 } unique ." "H{ { 1 1 } { 2 2 } { 3 3 } }" }
} ;

HELP: prune
{ $values { "seq" "a sequence" } { "newseq" "a sequence" } }
{ $description "Outputs a new sequence with each distinct element of " { $snippet "seq" } " appearing only once. Elements are compared for equality using " { $link = } " and elements are ordered according to their position in " { $snippet "seq" } "." }
{ $examples
    { $example "USING: sequences prettyprint ;" "{ 1 1 t 3 t } prune ." "V{ 1 t 3 }" }
} ;

HELP: all-unique?
{ $values { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests whether a sequence contains any repeated elements." }
{ $example
    "USING: hashtables prettyprint ;"
    "{ 0 1 1 2 3 5 } all-unique? ."
    "f"
} ;

HELP: diff
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in " { $snippet "seq2" } " but not " { $snippet "seq1" } ", comparing elements for equality." 
} { $examples
    { $example "USING: sequences prettyprint ;" "{ 1 2 3 } { 2 3 4 } diff ." "{ 4 }" }
} ;

HELP: intersect
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in both " { $snippet "seq1" } " and " { $snippet "seq2" } "." }
{ $examples
    { $example "USING: sequences prettyprint ;" "{ 1 2 3 } { 2 3 4 } intersect ." "{ 2 3 }" }
} ;

HELP: union
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in " { $snippet "seq1" } " and " { $snippet "seq2" } " which does not contain duplicate values." }
{ $examples
    { $example "USING: sequences prettyprint ;" "{ 1 2 3 } { 2 3 4 } union ." "{ 1 2 3 4 }" }
} ;

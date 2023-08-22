! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences sets ;
IN: sets.extras

HELP: setwise-xor
{ $values
    { "seq1" sequence } { "seq2" sequence }
    { "set" set }
}
{ $description "Converts the sequences to sets and takes the element-wise " { $link xor } ". Outputs elements that are in either set but not in both." }
{ $example
    "USING: sets.extras prettyprint ;"
    "{ 1 2 3 } { 2 3 4 } setwise-xor ."
    "{ 1 4 }"
}
{ $notes "Known as setxor1d in numpy." } ;

HELP: symmetric-diff
{ $values { "set1" set } { "set2" set } { "set" set } }
{ $description "Find the symmetric difference of two sets. Outputs a set containing elements that in either set but not in both." } ;

HELP: proper-subset?
{ $values { "set1" set } { "set2" set } { "?" boolean } }
{ $description "Find whether " { $snippet "set1" } " is a proper subset of " { $snippet "set2" } ". Returns true if " { $snippet "set1" } " is a subset of " { $snippet "set2" } " but " { $snippet "set2" } " is not a subset of " { $snippet "set1" } "." } ;

ARTICLE: "sets.extras" "Extra sets words"
"The " { $vocab-link "sets.extras" } " vocabulary is a collection of words related to sets."
$nl
"To take the element-wise xor of two sequences as if they were sets:"
{ $subsections setwise-xor } ;

ABOUT: "sets.extras"

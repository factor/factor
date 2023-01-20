! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences ;
IN: sorting.human

HELP: find-numbers
{ $values
    { "sequence" sequence }
    { "sequence'" sequence }
}
{ $description "Splits a string on numbers and returns a sequence of sequences and integers." } ;

HELP: human<=>
{ $values
    { "obj1" object } { "obj2" object }
    { "<=>" "an ordering specifier" }
}
{ $description "Compares two objects after converting numbers in the string into integers." } ;

HELP: human>=<
{ $values
    { "obj1" object } { "obj2" object }
    { ">=<" "an ordering specifier" }
}
{ $description "Compares two objects using the " { $link human<=> } " word and inverts the result." } ;

ARTICLE: "sorting.human" "Human-friendly sorting"
"The " { $vocab-link "sorting.human" } " vocabulary sorts by numbers as a human would -- by comparing their magnitudes -- rather than in a lexicographic way. For example, sorting a1, a10, a03, a2 with human sort returns a1, a2, a03, a10, while sorting with natural sort returns a03, a1, a10, a2." $nl
"Comparing two objects:"
{ $subsections
    human<=>
    human>=<
}
"Splitting a string into substrings and integers:"
{ $subsections find-numbers } ;

ABOUT: "sorting.human"

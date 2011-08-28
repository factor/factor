! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types help.markup help.syntax kernel quotations
sequences strings ;
IN: tools.coverage

HELP: <coverage>
{ $values
    { "executed?" boolean }
    { "coverage" coverage }
}
{ $description "Makes a coverage tuple. Users should not call this directly." } ; 

HELP: each-word
{ $values
    { "string" string } { "quot" quotation }    
}
{ $description "Calls a quotation on every word in the vocabulary and its private vocabulary, if there is one." } ;

HELP: map-words
{ $values
    { "string" string } { "quot" quotation }
    { "sequence" sequence }
}
{ $description "Calls a quotation on every word in the vocabulary and its private vocabulary, if there is one, and collects the results." } ;

HELP: coverage
{ $values
    { "object" object }
    { "seq" sequence }
}
{ $description "Outputs a sequence of quotations that were not called since coverage tracking was enabled. If the input is a string, the output is an alist of word-name/quotations that were not used. If the input is a word name, the output is a sequence of quotations." } ;

HELP: coverage-off
{ $values
    { "object" object }    
}
{ $description "Deactivates the coverage tool on a word or vocabulary and its private vocabulary." } ;

HELP: coverage-on
{ $values
    { "object" object }    
}
{ $description "Activates the coverage tool on a word or vocabulary and its private vocabulary." } ;

HELP: toggle-coverage
{ $values
    { "object" object }
}
{ $description "Toggles whether the coverage tool is active on a word or vocabulary and its private vocabulary." } ;

HELP: coverage.
{ $values
    { "object" object }    
}
{ $description "Calls the coverage word on all the words in a vocabalary or on a single word and prints out a report." } ;

HELP: %coverage
{ $values
    { "string" string }
    { "x" double }
}
{ $description "Returns a fraction representing the number of quotations called compared to the number of quotations that exist in a vocabulary or word." } ;

ARTICLE: "tools.coverage" "Coverage tool"
"The " { $vocab-link "tools.coverage" } " vocabulary is a tool for testing code coverage. The implementation uses " { $vocab-link "tools.annotations" } " to place a coverage object at the beginning of every quotation. When the quotation executes, a slot on the coverage object is set to true. By examining the coverage objects after running the code for some time, one can see which of the quotations did not execute and write more tests or refactor the code." $nl
"Enabling/disabling coverage:"
{ $subsections coverage-on coverage-off toggle-coverage }
"Examining coverage data:"
{ $subsections coverage coverage. %coverage }
"Combinators for iterating over words in a vocabulary:"
{ $subsections each-word map-words } ;

ABOUT: "tools.coverage"

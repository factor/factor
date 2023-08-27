! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types assocs help.markup help.syntax kernel quotations
sequences strings ;
IN: tools.coverage

HELP: <coverage-state>
{ $values
    { "executed?" boolean }
    { "coverage-state" coverage-state }
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
{ $description "Deactivates the coverage tool on a word or vocabulary and its private vocabulary." } ;

HELP: coverage-on
{ $description "Activates the coverage tool on a word or vocabulary and its private vocabulary." } ;

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

HELP: add-coverage
{ $values
    { "object" object }
}
{ $description "Recompiles a vocabulary with the coverage annotation. Note that the annotation tool is still disabled until you call " { $link coverage-on } "." } ;

HELP: covered
{ $values
        { "value" object }
}
{ $description "The value that determines whether coverage will set the " { $snippet "executed?" } " slot when code runs." } ;

HELP: flag-covered
{ $values
    { "coverage" object }
}
{ $description "A word that sets the " { $snippet "executed?" } " slot of the coverage tuple when the covered value is true." } ;

HELP: remove-coverage
{ $values
    { "object" object }
}
{ $description "Recompiles a vocabulary without the coverage annotation." } ;

HELP: reset-coverage
{ $values
    { "object" object }
}
{ $description "Sets the " { $snippet "execute?" } " slot of each coverage tuple to false." } ;

HELP: test-coverage
{ $values
    { "vocab" "a vocabulary specifier" }
    { "coverage" sequence }
}
{ $description "Enables code coverage for a vocabulary and runs its unit tests. The returned value is a sequence of pairs containing names and quotations which did not execute." } ;

HELP: test-coverage-recursively
{ $values
    { "prefix" "a vocabulary name" }
    { "assoc" assoc }
}
{ $description "Enables code coverage for the vocabulary named " { $snippet "prefix" } " and all of its child vocabularies." } ;

ARTICLE: "tools.coverage" "Coverage tool"
"The " { $vocab-link "tools.coverage" } " vocabulary is a tool for testing code coverage. The implementation uses " { $vocab-link "tools.annotations" } " to place a coverage object at the beginning of every quotation. When the quotation executes, a slot on the coverage object is set to true. By examining the coverage objects after running the code for some time, one can see which of the quotations did not execute and write more tests or refactor the code." $nl
"An example of using the coverage tool by hand would be to call " { $link add-coverage } " and then call " { $link coverage-on } ". Next, run whatever code you think will call the most quotations in the code you're testing, and then run the " { $link coverage. } " word on your vocabulary to see which quotations didn't get run." $nl
"A fully automated way to test the unit-test coverage of a vocabulary is the " { $link test-coverage } " word." $nl
"Adding coverage annotations to a vocabulary:"
{ $subsections add-coverage remove-coverage }
"Resetting coverage annotations:"
{ $subsections reset-coverage }
"Enabling/disabling coverage:"
{ $subsections coverage-on coverage-off }
"Examining coverage data:"
{ $subsections coverage coverage. %coverage }
"Gather unit-test coverage data for a vocabulary:"
{ $subsections test-coverage }
"Combinators for iterating over words in a vocabulary:"
{ $subsections each-word map-words } ;

ABOUT: "tools.coverage"

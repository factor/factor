USING: help.markup help.syntax kernel ;
IN: tools.test

ARTICLE: "tools.test" "Unit testing modules"
"A unit test is a piece of code which starts with known input values, then compares the output of a word with an expected output, where the expected output is defined by the word's contract."
$nl
"For example, if you were developing a word for computing symbolic derivatives, your unit tests would apply the word to certain input functions, comparing the results against the correct values. While the passing of these tests would not guarantee the algorithm is correct, it would at least ensure that what used to work keeps working, in that as soon as something breaks due to a change in another part of your program, failing tests will let you know."
$nl
"Unit tests for a vocabulary are placed in test harness files ( "{ $link "vocabs.loader" } "). If the test harness needs to define words, they should be placed in the " { $snippet "temporary" } " vocabulary so that they can be forgotten after the tests have been run. Test harness files consist mostly of calls to the following two words:"
{ $subsection unit-test }
{ $subsection unit-test-fails }
"The following words run test harness files; any test failures are collected and printed at the end:"
{ $subsection test }
{ $subsection test-all } ;

ABOUT: "tools.test"

HELP: unit-test
{ $values { "output" "a sequence of expected stack elements" } { "input" "a quotation run with an empty stack" } }
{ $description "Runs a quotation with an empty stack, comparing the resulting stack with " { $snippet "output" } ". Elements are compared using " { $link = } ". Throws an error if the expected stack does not match the resulting stack." } ;

HELP: unit-test-fails
{ $values { "quot" "a quotation run with an empty stack" } }
{ $description "Runs a quotation with an empty stack, expecting it to throw an error. If the quotation throws an error, this word returns normally. If the quotation does not throw an error, this word " { $emphasis "does" } " raise an error." }
{ $notes "This word is used to test boundary conditions and fail-fast behavior." } ;

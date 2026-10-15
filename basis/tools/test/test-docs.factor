USING: help.markup help.syntax kernel quotations io strings vocabs.refresh ;
IN: tools.test

ARTICLE: "tools.test" "Unit testing"
"A unit test is a piece of code which starts with known input values, then compares the output of a word with an expected output, where the expected output is defined by the word's contract."
$nl
"For example, if you were developing a word for computing symbolic derivatives, your unit tests would apply the word to certain input functions, comparing the results against the correct values. While the passing of these tests would not guarantee the algorithm is correct, it would at least ensure that what used to work keeps working, in that as soon as something breaks due to a change in another part of your program, failing tests will let you know."
$nl
"Unit tests for a vocabulary are placed in test files in the same directory as the vocabulary source file (see " { $link "vocabs.loader" } "). Two possibilities are supported:"
{ $list
    { "Tests can be placed in a file named " { $snippet { $emphasis "vocab" } "-tests.factor" } "." }
    { "Tests can be placed in files in the " { $snippet "tests" } " subdirectory." }
}
"The latter is used for vocabularies with more extensive test suites."
$nl
"Each test file runs with default prettyprinter settings, independent of the caller's display preferences. Tests can override these settings explicitly."
$nl
"If the test harness needs to define words, they should be placed in a vocabulary named " { $snippet { $emphasis "vocab" } ".tests" } " where " { $emphasis "vocab" } " is the vocab being tested."
{ $heading "Writing unit tests" }
"Several words exist for writing different kinds of unit tests. The most general one asserts that a quotation outputs a specific set of values:"
{ $subsections POSTPONE: unit-test }
"Assert that a quotation throws an error:"
{ $subsections
    POSTPONE: must-fail
    POSTPONE: must-fail-with
}
"Assert that a quotation or word has a specific static stack effect (see " { $link "inference" } "):"
{ $subsections
    POSTPONE: must-infer
    POSTPONE: must-infer-as
}
"All of the above are used like ordinary words but are actually parsing words. This ensures that parse-time state, namely the line number, can be associated with the test in question, and reported in test failures."
$nl
"Some words help the test writer using temporary files:"
{ $subsections
  with-test-directory
  with-test-file
}
{ $heading "Running unit tests" }
"The following words run test harness files; any test failures are collected and printed at the end:"
{ $subsections
    test
    test-all
}
"The following word prints failures:"
{ $subsections :test-failures }
"Test failures are reported using the " { $link "tools.errors" } " mechanism and are shown in the " { $link "ui.tools.error-list" } "."
$nl
"Unit test failures are instances of a class, and are stored in a global variable:"
{ $subsections
    test-failure
    test-failures
} ;



HELP: must-fail
{ $syntax "[ quot ] must-fail" }
{ $values { "quot" "a quotation run with an empty stack" } }
{ $description "Runs a quotation with an empty stack, expecting it to throw an error. If the quotation throws an error, this word returns normally. If the quotation does not throw an error, this word " { $emphasis "does" } " raise an error." }
{ $notes "This word is used to test boundary conditions and fail-fast behavior." } ;

HELP: must-fail-with
{ $syntax "[ quot ] [ pred ] must-fail-with" }
{ $values { "quot" "a quotation run with an empty stack" } { "pred" { $quotation ( error -- ? ) } } }
{ $description "Runs a quotation with an empty stack, expecting it to throw an error which must satisfy " { $snippet "pred" } ". If the quotation does not throw an error, or if the error does not match the predicate, the unit test fails." }
{ $notes "This word is used to test error handling code, ensuring that errors thrown by code contain the relevant debugging information." } ;

HELP: must-infer
{ $syntax "[ quot ] must-infer" }
{ $values { "quot" quotation } }
{ $description "Ensures that the quotation has a static stack effect without running it." }
{ $notes "This word is used to test that code will compile with the optimizing compiler for optimum performance. See " { $link "compiler" } "." } ;

HELP: must-infer-as
{ $syntax "{ effect } [ quot ] must-infer-as" }
{ $values { "effect" "a pair with shape " { $snippet "{ inputs outputs }" } } { "quot" quotation } }
{ $description "Ensures that the quotation has the indicated stack effect without running it." }
{ $notes "This word is used to test that code will compile with the optimizing compiler for optimum performance. See " { $link "compiler" } "." } ;

HELP: test
{ $values { "prefix" "a vocabulary name" } }
{ $description "Runs unit tests for the vocabulary named " { $snippet "prefix" } " and all of its child vocabularies." } ;

HELP: test-all
{ $description "Runs unit tests for all loaded vocabularies." } ;

HELP: refresh-and-test
{ $values { "prefix" string } }
{ $description "Like " { $link refresh } ", but runs unit tests for all reloaded vocabularies afterwards." } ;

HELP: refresh-and-test-all
{ $description "Like " { $link refresh-all } ", but runs unit tests for all reloaded vocabularies afterwards." } ;

{ refresh-and-test refresh-and-test-all } related-words

HELP: :test-failures
{ $description "Prints all pending unit test failures." } ;

HELP: unit-test
{ $syntax "{ output } [ input ] unit-test" }
{ $values { "output" "a sequence of expected stack elements" } { "input" "a quotation run with an empty stack" } }
{ $description "Runs a quotation with an empty stack, comparing the resulting stack with " { $snippet "output" } ". Elements are compared using " { $link = } ". Throws an error if the expected stack does not match the resulting stack." } ;

HELP: with-test-file
{ $values { "quot" quotation } }
{ $description "Creates an empty temporary file and applies the quotation to it. The file is deleted after the word returns." } ;

ABOUT: "tools.test"

HELP: floating-point-unit-test
{ $syntax "{ expected... } [ quot ] floating-point-unit-test" }
{ $description "Runs an ordinary unit test when the runtime supports floating point. Otherwise records an unsupported test in " { $link test-skips } " with its experiment, file, line number and reason. Use this form only for a case that executes floating-point operations; integer cases and tests of opaque floating-point metadata remain ordinary tests." } ;

HELP: test-skips
{ $description "A sequence of skipped test records, separate from test failures. Each record retains the reason, experiment, source file and line number. Skipped tests are not passing tests." } ;

HELP: floating-point-unit-test~
{ $syntax "{ expected... tolerance } [ quot ] floating-point-unit-test~" }
{ $description "The capability-aware form of approximate scalar comparison. Records an unsupported test when floating point is unavailable." } ;

HELP: floating-point-unit-test-v~
{ $syntax "{ expected... tolerance } [ quot ] floating-point-unit-test-v~" }
{ $description "The capability-aware form of approximate vector comparison. Records an unsupported test when floating point is unavailable." } ;

HELP: floating-point-must-not-fail
{ $syntax "[ quot ] floating-point-must-not-fail" }
{ $description "Runs a quotation expecting no error when floating point is supported; otherwise records an unsupported test." } ;

HELP: floating-point-must-fail
{ $syntax "[ quot ] floating-point-must-fail" }
{ $description "Tests failure of a quotation requiring floating-point execution. Records an unsupported test when floating point is unavailable. Tests of the unsupported-operation error itself must use ordinary must-fail or must-fail-with so they remain enabled." } ;

HELP: floating-point-must-fail-with
{ $syntax "[ quot ] [ pred ] floating-point-must-fail-with" }
{ $description "Tests a specific failure of a quotation requiring floating-point execution. Records an unsupported test when floating point is unavailable. Tests of unsupported-operation rejection must use ordinary must-fail-with." } ;

HELP: :test-skips
{ $description "Prints every skipped test record with its reason, experiment, source file and line number. The command-line test runner prints these records after the separate skipped count." } ;

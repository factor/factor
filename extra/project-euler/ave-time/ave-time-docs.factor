USING: help.markup help.syntax math quotations sequences ;
IN: project-euler.ave-time

HELP: collect-benchmarks
{ $values { "quot" quotation } { "n" integer } { "seq" sequence } }
{ $description "Runs a quotation " { $snippet "n" } " times, collecting the wall clock time inside of a sequence." }
{ $notes "The stack effect of " { $snippet "quot" } " is accounted for and only one set of outputs will remain on the stack no matter how many trials are run."
    $nl
    "A nicer word for interactive use is " { $link ave-time } "." } ;

HELP: ave-time
{ $values { "quot" quotation } { "n" integer } }
{ $description "Runs a quotation " { $snippet "n" } " times, then prints the average run time and standard deviation." }
{ $notes "The stack effect of " { $snippet "quot" } " is accounted for and only one set of outputs will remain on the stack no matter how many trials are run." }
{ $examples
    "This word can be used to compare performance of the non-optimizing and optimizing compilers."
    $nl
    "First, we time a quotation directly; quotations are compiled by the non-optimizing quotation compiler:"
    { $unchecked-example "[ 1000000 0 [ + ] reduce drop ] 10 ave-time" "465 ms ave run time - 13.37 SD (10 trials)" }
    "Now we define a word and compile it with the optimizing word compiler. This results in faster execution:"
    { $unchecked-example ": foo 1000000 0 [ + ] reduce ;" "\\ foo compile" "[ foo drop ] 10 ave-time" "202 ms ave run time - 22.73 SD (10 trials)" }
} ;

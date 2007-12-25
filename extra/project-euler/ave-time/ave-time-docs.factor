USING: arrays help.markup help.syntax math memory quotations sequences system tools.time ;
IN: project-euler.ave-time

HELP: collect-benchmarks
{ $values { "quot" quotation } { "n" integer } { "seq" sequence } }
{ $description "Runs a quotation " { $snippet "n" } " times, collecting the wall clock time and the time spent in the garbage collector into pairs inside of a sequence." }
{ $notes "The stack effect of " { $snippet "quot" } " is inferred and only one set of outputs will remain on the stack no matter how many trials are run."
    $nl
    "A nicer word for interactive use is " { $link ave-time } "." } ;

HELP: ave-time
{ $values { "quot" quotation } { "n" integer } }
{ $description "Runs a quotation " { $snippet "n" } " times, then prints the average run time and the average time spent in the garbage collector." }
{ $notes "The stack effect of " { $snippet "quot" } " is inferred and only one set of outputs will remain on the stack no matter how many trials are run." }
{ $examples
    "This word can be used to compare performance of the non-optimizing and optimizing compilers."
    $nl
    "First, we time a quotation directly; quotations are compiled by the non-optimizing quotation compiler:"
    { $unchecked-example "[ 1000000 0 [ + ] reduce drop ] 10 ave-time" "1116 ms run / 6 ms GC ave time - 10 trials" }
    "Now we define a word and compile it with the optimizing word compiler. This results is faster execution:"
    { $unchecked-example ": foo 1000000 0 [ + ] reduce ;" "\\ foo compile" "[ foo drop ] 10 ave-time" "202 ms run / 13 ms GC ave time - 10 trials" }
} ;

{ benchmark collect-benchmarks gc-time millis time ave-time } related-words

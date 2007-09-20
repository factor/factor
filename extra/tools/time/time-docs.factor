USING: help.markup help.syntax memory system ;
IN: tools.time

ARTICLE: "timing" "Timing code"
"You can time the execution of a quotation in the listener:"
{ $subsection time }
"A lower-level word puts timings on the stack, intead of printing:"
{ $subsection benchmark }
"You can also read the system clock and total garbage collection time directly:"
{ $subsection millis } 
{ $subsection gc-time }
{ $see-also "profiling" } ;

ABOUT: "timing"

HELP: benchmark
{ $values { "quot" "a quotation" } { "gctime" "an integer denoting milliseconds" } { "runtime" "an integer denoting milliseconds" } }
{ $description "Runs a quotation, measuring the total wall clock time and the total time spent in the garbage collector." }
{ $notes "A nicer word for interactive use is " { $link time } "." } ;

HELP: time
{ $values { "quot" "a quotation" } }
{ $description "Runs a quotation and then prints the total run time and time spent in the garbage collector." }
{ $examples
    "This word can be used to compare performance of the non-optimizing and optimizing compilers."
    $nl
    "First, we time a quotation directly; quotations are compiled by the non-optimizing quotation compiler:"
    { $unchecked-example "[ 1000000 0 [ + ] reduce drop ] time" "1116 ms run / 6 ms GC time" }
    "Now we define a word and compile it with the optimizing word compiler. This results is faster execution:"
    { $unchecked-example ": foo 1000000 0 [ + ] reduce ;" "\\ foo compile" "[ foo drop ] time" "202 ms run / 13 ms GC time" }
} ;

{ gc-time benchmark millis time } related-words

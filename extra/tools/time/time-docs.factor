USING: help.markup help.syntax memory system ;
IN: tools.time

ARTICLE: "timing" "Timing code"
"You can time the execution of a quotation in the listener:"
{ $subsection time }
"A lower-level word puts timings on the stack, intead of printing:"
{ $subsection benchmark }
"You can also read the system clock and garbage collection statistics directly:"
{ $subsection millis } 
{ $subsection gc-stats }
{ $see-also "profiling" } ;

ABOUT: "timing"

HELP: benchmark
{ $values { "quot" "a quotation" }
          { "runtime" "an integer denoting milliseconds" } }
{ $description "Runs a quotation, measuring the total wall clock time and the total time spent in the garbage collector." }
{ $notes "A nicer word for interactive use is " { $link time } "." } ;

HELP: time
{ $values { "quot" "a quotation" } }
{ $description "Runs a quotation and then prints the total run time and some garbage collection statistics." } ;

{ benchmark millis time } related-words

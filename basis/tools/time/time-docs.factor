USING: help.markup help.syntax memory system ;
IN: tools.time

ARTICLE: "timing" "Timing code"
"You can time the execution of a quotation in the listener:"
{ $subsections time }
"A lower-level word puts timings on the stack, intead of printing:"
{ $subsections benchmark }
"You can also read the system clock directly:"
{ $subsections micros }
{ $see-also "profiling" "calendar" } ;

ABOUT: "timing"

HELP: benchmark
{ $values { "quot" "a quotation" }
          { "runtime" "the runtime in microseconds" } }
      { $description "Runs a quotation, measuring the total wall clock time." }
{ $notes "A nicer word for interactive use is " { $link time } "." } ;

HELP: time
{ $values { "quot" "a quotation" } }
{ $description "Runs a quotation and then prints the total run time and some statistics." } ;

{ benchmark micros time } related-words

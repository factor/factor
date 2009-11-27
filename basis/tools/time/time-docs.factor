USING: help.markup help.syntax memory system tools.dispatch
tools.memory quotations vm ;
IN: tools.time

ARTICLE: "timing" "Timing code and collecting statistics"
"You can time the execution of a quotation in the listener:"
{ $subsections time }
"This word also collects statistics about method dispatch and garbage collection:"
{ $subsections dispatch-stats. gc-events. gc-stats. gc-summary. }
"A lower-level word puts timings on the stack, intead of printing:"
{ $subsections benchmark }
"You can also read the system clock directly; see " { $link "system" } "."
{ $see-also "profiling" "calendar" } ;

ABOUT: "timing"

HELP: benchmark
{ $values { "quot" quotation }
          { "runtime" "the runtime in microseconds" } }
      { $description "Runs a quotation, measuring the total wall clock time." }
{ $notes "A nicer word for interactive use is " { $link time } "." } ;

HELP: time
{ $values { "quot" quotation } }
{ $description "Runs a quotation, gathering statistics about method dispatch and garbage collection, and then prints the total run time." } ;

{ benchmark system-micros time } related-words

HELP: collect-gc-events
{ $values { "quot" quotation } }
{ $description "Calls the quotation, storing an array of " { $link gc-event } " instances in the " { $link gc-events } " variable." }
{ $notes "The " { $link time } " combinator automatically calls this combinator." } ;

HELP: collect-dispatch-stats
{ $values { "quot" quotation } }
{ $description "Calls the quotation, collecting method dispatch statistics and storing them in the " { $link last-dispatch-stats } " variable. " }
{ $notes "The " { $link time } " combinator automatically calls this combinator." } ;

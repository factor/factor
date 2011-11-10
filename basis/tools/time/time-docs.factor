USING: help.markup help.syntax memory system tools.dispatch
tools.memory quotations vm ;
IN: tools.time

ARTICLE: "timing" "Timing code and collecting statistics"
"You can time the execution of a quotation in the listener:"
{ $subsections time }
"This word also collects statistics about method dispatch and garbage collection:"
{ $subsections dispatch-stats. gc-events. gc-stats. gc-summary. }
"A lower-level word puts timings on the stack, instead of printing:"
{ $subsections benchmark }
"You can also read the system clock directly; see " { $link "system" } "."
{ $see-also "tools.profiler.sampling" "tools.annotations" "calendar" } ;

ABOUT: "timing"

HELP: benchmark
{ $values { "quot" quotation }
          { "runtime" "the runtime in nanoseconds" } }
      { $description "Runs a quotation, measuring the total wall clock time." }
{ $notes "A nicer word for interactive use is " { $link time } "." } ;

HELP: time
{ $values { "quot" quotation } }
{ $description "Runs a quotation, gathering statistics about method dispatch and garbage collection, and then prints the total run time." } ;

{ benchmark time } related-words

HELP: collect-gc-events
{ $values { "quot" quotation } { "gc-events" "a sequence of " { $link gc-event } " instances" } }
{ $description "Calls the quotation and outputs a sequence of " { $link gc-event } " instances." }
{ $notes "The " { $link time } " combinator automatically calls this combinator." } ;

HELP: collect-dispatch-stats
{ $values { "quot" quotation } { "dispatch-statistics" dispatch-statistics } }
{ $description "Calls the quotation and outputs a " { $link dispatch-statistics } " instance." }
{ $notes "The " { $link time } " combinator automatically calls this combinator." } ;

IN: io.timeouts
USING: help.markup help.syntax math kernel calendar ;

HELP: timeout
{ $values { "obj" object } { "dt/f" { $maybe duration } } }
{ $contract "Outputs an object's timeout." } ;

HELP: set-timeout
{ $values { "dt/f" { $maybe duration } } { "obj" object } }
{ $contract "Sets an object's timeout." }
{ $examples "Waits five seconds for a process that sleeps for ten seconds:"
  { $unchecked-example
    "USING: calendar io.launcher io.timeouts kernel ;"
    "\"sleep 10\" >process 5 seconds over set-timeout run-process"
    "Process was killed as a result of a call to kill-process, or a timeout"
  }
} ;

HELP: cancel-operation
{ $values { "obj" object } }
{ $contract "Handles a timeout, usually by waking up all threads waiting on the object." } ;

HELP: with-timeout
{ $values { "obj" object } { "quot" { $quotation ( obj -- ) } } }
{ $description "Applies the quotation to the object. If the object's timeout expires before the quotation returns, " { $link cancel-operation } " is called on the object." } ;

ARTICLE: "io.timeouts" "I/O timeout protocol"
"Streams, processes and monitors support optional timeouts, which impose an upper bound on the length of time for which an operation on these objects can block. Timeouts are used in network servers to prevent malicious clients from holding onto connections forever, and to ensure that runaway processes get killed."
{ $subsections
    timeout
    set-timeout
}
"The I/O timeout protocol can be implemented by any class wishing to support timeouts on blocking operations."
{ $subsections cancel-operation }
"A combinator to be used in operations which can time out:"
{ $subsections with-timeout }
{ $see-also "stream-protocol" "io.launcher" "io.monitors" } ;

ABOUT: "io.timeouts"

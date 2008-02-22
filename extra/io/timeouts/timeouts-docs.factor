IN: io.timeouts
USING: help.markup help.syntax math kernel calendar ;

HELP: timeout
{ $values { "obj" object } { "dt/f" "a " { $link dt } " or " { $link f } } }
{ $contract "Outputs an object's timeout." } ;

HELP: set-timeout
{ $values { "dt/f" "a " { $link dt } " or " { $link f } } { "obj" object } }
{ $contract "Sets an object's timeout." } ;

HELP: timed-out
{ $values { "obj" object } }
{ $contract "Handles a timeout, usually by waking up all threads waiting on the object." } ;

HELP: with-timeout
{ $values { "obj" object } { "quot" "a quotation with stack effect " { $snippet "( obj -- )" } } }
{ $description "Applies the quotation to the object. If the object's timeout expires before the quotation returns, " { $link timed-out } " is called on the object." } ;

ARTICLE: "io.timeouts" "I/O timeout protocol"
"Streams and processes support optional timeouts, which impose an upper bound on the length of time for which an operation on these objects can block. Timeouts are used in network servers to prevent malicious clients from holding onto connections forever, and to ensure that runaway processes get killed."
{ $subsection timeout }
{ $subsection set-timeout }
"The I/O timeout protocol can be implemented by any class wishing to support timeouts on blocking operations."
{ $subsection timed-out }
"A combinator to be used in operations which can time out:"
{ $subsection with-timeout }
{ $see-also "stream-protocol" "io.launcher" }
;

ABOUT: "io.timeouts"

! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.messaging kernel arrays
continuations help.markup help.syntax quotations calendar ;
IN: concurrency.promises

HELP: promise
{ $class-description "The class of write-once promises." } ;

HELP: <promise>
{ $values { "promise" promise } }
{ $description "Creates a new promise which may be fulfilled by calling " { $link fulfill } "." } ;

HELP: promise-fulfilled?
{ $values { "promise" promise } { "?" "a boolean" } }
{ $description "Tests if " { $link fulfill } " has previously been called on the promise, in which case " { $link ?promise } " will return immediately without blocking." } ;

HELP: ?promise-timeout
{ $values { "promise" promise } { "timeout" { $maybe duration } } { "result" object } }
{ $description "Waits for another thread to fulfill a promise, returning immediately if the promise has already been fulfilled. A timeout of " { $link f } " indicates that the thread may block indefinitely, otherwise it will wait up to the " { $snippet "timeout" } " before throwing an error." }
{ $errors "Throws an error if the timeout expires before the promise has been fulfilled." } ;

HELP: ?promise
{ $values { "promise" promise } { "result" object } }
{ $description "Waits for another thread to fulfill a promise, returning immediately if the promise has already been fulfilled." } ;

HELP: fulfill
{ $values { "value" object } { "promise" promise } }
{ $description "Fulfills a promise by writing a value to it. Any threads waiting for the value are notified." }
{ $errors "Throws an error if the promise has already been fulfilled." } ;

ARTICLE: "concurrency.promises" "Promises"
"The " { $vocab-link "concurrency.promises" } " vocabulary implements " { $emphasis "promises" } ", which are thread-safe write-once variables. Once a promise is created, threads may block waiting for it to be " { $emphasis "fulfilled" } "; at some point in the future, another thread may provide a value at which point all waiting threads are notified."
{ $subsection promise }
{ $subsection <promise> }
{ $subsection fulfill }
{ $subsection ?promise }
{ $subsection ?promise-timeout } ;

ABOUT: "concurrency.promises"

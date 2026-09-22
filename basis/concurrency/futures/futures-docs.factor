! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: concurrency.promises concurrency.messaging kernel arrays
continuations help.markup help.syntax quotations calendar ;
IN: concurrency.futures

HELP: future
{ $values { "quot" { $quotation ( -- value ) } } { "future" future } }
{ $description "Creates a deferred computation."
$nl
"The quotation begins with an empty data stack and an empty catch stack. It inherits the caller's name stack, so dynamically scoped variables are available to the deferred computation. Data can also be passed by partial application, for example using " { $link curry } " or " { $link compose } "." } ;

HELP: ?future-timeout
{ $values { "future" future } { "timeout" { $maybe duration } } { "value" object } }
{ $description "Waits for a deferred computation to complete, blocking indefinitely if " { $snippet "timeout" } " is " { $link f } ", otherwise waiting up to the " { $snippet "timeout" } " before throwing an error." }
{ $errors "Throws an error if the timeout expires before the computation completes. Also throws an error if the future quotation threw an error." } ;

HELP: ?future
{ $values { "future" future } { "value" object } }
{ $description "Waits for a deferred computation to complete, blocking indefinitely." }
{ $errors "Throws an error if future quotation threw an error." } ;

ARTICLE: "concurrency.futures" "Futures"
"The " { $vocab-link "concurrency.futures" } " vocabulary implements " { $emphasis "futures" } ", which are deferred computations performed in a background thread. A thread may create a future, then proceed to perform other tasks, then later wait for the future to complete."
{ $subsections
    future
    ?future
    ?future-timeout
} ;

ABOUT: "concurrency.futures"

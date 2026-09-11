USING: accessors calendar continuations io.timeouts kernel
threads tools.test ;
IN: io.timeouts.tests

TUPLE: cancellation-probe cancelled? ;
M: cancellation-probe cancel-operation t >>cancelled? drop ;

! An old operation's timer must not cancel a subsequent operation.
{ f } [
    cancellation-probe new dup [
        10 milliseconds [ drop "operation failed" throw ] with-timeout*
    ] [ 2drop ] recover
    50 milliseconds sleep cancelled?>>
] unit-test

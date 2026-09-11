USING: concurrency.mailboxes concurrency.count-downs concurrency.conditions
vectors sequences threads tools.test math kernel strings namespaces
continuations calendar destructors locals system timers ;
IN: concurrency.mailboxes.tests

{ 1 1 } [ [ integer? ] mailbox-get? ] must-infer-as

{ V{ 1 2 3 } } [
    0 <vector>
    <mailbox>
    [ mailbox-get swap push ] in-thread
    [ mailbox-get swap push ] in-thread
    [ mailbox-get swap push ] in-thread
    1 over mailbox-put
    2 over mailbox-put
    3 swap mailbox-put
] unit-test

{ V{ 1 2 3 } } [
    0 <vector>
    <mailbox>
    [ [ integer? ] mailbox-get? swap push ] in-thread
    [ [ integer? ] mailbox-get? swap push ] in-thread
    [ [ integer? ] mailbox-get? swap push ] in-thread
    1 over mailbox-put
    2 over mailbox-put
    3 swap mailbox-put
] unit-test

{ V{ 1 "junk" 3 "junk2" } [ 456 ] } [
    0 <vector>
    <mailbox>
    [ [ integer? ] mailbox-get? swap push ] in-thread
    [ [ integer? ] mailbox-get? swap push ] in-thread
    [ [ string? ] mailbox-get? swap push ] in-thread
    [ [ string? ] mailbox-get? swap push ] in-thread
    1 over mailbox-put
    "junk" over mailbox-put
    [ 456 ] over mailbox-put
    3 over mailbox-put
    "junk2" over mailbox-put
    mailbox-get
] unit-test

{ V{ "foo" "bar" } } [
    <mailbox>
    "foo" over mailbox-put
    "bar" over mailbox-put
    mailbox-get-all
] unit-test

[
    <mailbox> 1 seconds mailbox-get-timeout
] [ timed-out-error? ] must-fail-with

{ t } [ <mailbox> mailbox-empty? ] unit-test
{ f } [ <mailbox> "foo" over mailbox-put mailbox-empty? ] unit-test

! Unmatched incoming messages must not restart a selective receive's timeout.
:: selective-receive-deadline-test ( -- ? )
    <mailbox> :> mailbox
    [ "unmatched" mailbox mailbox-put ] 10 milliseconds every :> notifier
    [ notifier stop-timer ] 500 milliseconds later :> stopper
    nano-count :> started
    [
        [ mailbox 30 milliseconds [ drop f ] mailbox-get-timeout? ]
        [ timed-out-error? ] must-fail-with
        nano-count started - 250000000 <
    ] [ notifier stop-timer stopper stop-timer ] finally ;

{ t } [ selective-receive-deadline-test ] unit-test

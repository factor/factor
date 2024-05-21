USING: concurrency.mailboxes concurrency.count-downs concurrency.conditions
vectors sequences threads tools.test math kernel strings namespaces
continuations calendar destructors ;
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

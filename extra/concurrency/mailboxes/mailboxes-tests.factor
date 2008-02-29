IN: temporary
USING: concurrency.mailboxes vectors sequences threads
tools.test math kernel strings ;

[ V{ 1 2 3 } ] [
    0 <vector>
    <mailbox>
    [ mailbox-get swap push ] in-thread
    [ mailbox-get swap push ] in-thread
    [ mailbox-get swap push ] in-thread
    1 over mailbox-put
    2 over mailbox-put
    3 swap mailbox-put
] unit-test

[ V{ 1 2 3 } ] [
    0 <vector>
    <mailbox>
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    1 over mailbox-put
    2 over mailbox-put
    3 swap mailbox-put
] unit-test

[ V{ 1 "junk" 3 "junk2" } [ 456 ] ] [
    0 <vector>
    <mailbox>
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    [ [ string? ] swap mailbox-get? swap push ] in-thread
    [ [ string? ] swap mailbox-get? swap push ] in-thread
    1 over mailbox-put
    "junk" over mailbox-put
    [ 456 ] over mailbox-put
    3 over mailbox-put
    "junk2" over mailbox-put
    mailbox-get
] unit-test

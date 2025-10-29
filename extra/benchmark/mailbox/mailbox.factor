USING: concurrency.mailboxes fry kernel sequences ;
IN: benchmark.mailbox

: <hidden-mailbox> ( -- obj ) <mailbox> ;

: mailbox-benchmark ( -- )
    100,000 <iota> <hidden-mailbox> '[
        dup _ [ mailbox-put ] [ mailbox-get ] bi assert=
    ] each ;

MAIN: mailbox-benchmark

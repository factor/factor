IN: queues
USING: errors kernel lists math sequences vectors ;

TUPLE: queue in out ;

C: queue ( -- queue ) ;

: queue-empty? ( queue -- ? )
    dup queue-in swap queue-out or not ;

: enque ( obj queue -- )
    [ queue-in cons ] keep set-queue-in ;

: deque ( queue -- obj )
    dup queue-out [
        uncons rot set-queue-out
    ] [
        dup queue-in [
            reverse uncons pick set-queue-out
            f rot set-queue-in
        ] [
            "Empty queue" throw
        ] if*
    ] if* ;

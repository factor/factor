IN: queues
USING: errors kernel lists math sequences vectors ;

TUPLE: queue in out ;
C: queue ;
: queue-empty? dup queue-in swap queue-out or not ;
: enque [ queue-in cons ] keep set-queue-in ;
: (deque)
    dup queue-in [
        reverse uncons pick set-queue-out
        f rot set-queue-in
    ] [
        "Empty queue" throw
    ] if* ;
: deque
    dup queue-out [
        uncons rot set-queue-out
    ] [
        (deque)
    ] if* ;

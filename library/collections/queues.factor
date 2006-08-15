! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: queues
USING: errors kernel ;

TUPLE: entry obj next ;

C: entry ( obj -- entry ) [ set-entry-obj ] keep ;

TUPLE: queue head tail ;

C: queue ( -- queue ) ;

: queue-empty? ( queue -- ? ) queue-head not ;

: clear-queue ( queue -- )
    f over set-queue-head f swap set-queue-tail ;

: (enque) ( entry queue -- )
    [ set-queue-head ] 2keep set-queue-tail ;

: enque ( obj queue -- )
    >r <entry> r> dup queue-empty? [
        (enque)
    ] [
        [ queue-tail set-entry-next ] 2keep set-queue-tail
    ] if ;

: (deque) ( queue -- )
    dup queue-head over queue-tail eq? [
        clear-queue
    ] [
        dup queue-head entry-next swap set-queue-head
    ] if ;

TUPLE: empty-queue ;
: empty-queue ( -- * ) <empty-queue> throw ;

: deque ( queue -- obj )
    dup queue-empty? [
        empty-queue
    ] [
        dup queue-head entry-obj >r (deque) r>
    ] if ;

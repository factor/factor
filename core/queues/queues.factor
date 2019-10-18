! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: queues
USING: kernel inspector ;

TUPLE: entry obj next ;

: <entry> ( obj -- entry ) f entry construct-boa ;

TUPLE: queue head tail ;

: <queue> ( -- queue ) queue construct-empty ;

: queue-empty? ( queue -- ? ) queue-head not ;

: (enque) ( entry queue -- )
    [ set-queue-head ] 2keep set-queue-tail ;

: clear-queue ( queue -- )
    f swap (enque) ;

: enque ( elt queue -- )
    >r <entry> r> dup queue-empty? [
        (enque)
    ] [
        [ queue-tail set-entry-next ] 2keep set-queue-tail
    ] if ;

: clear-entry ( entry -- )
    f over set-entry-obj f swap set-entry-next ;

: (deque) ( queue -- )
    dup queue-head over queue-tail eq? [
        clear-queue
    ] [
        dup queue-head dup entry-next rot set-queue-head
        clear-entry
    ] if ;

TUPLE: empty-queue-error ;
: empty-queue-error ( -- * )
    \ empty-queue-error construct-empty throw ;

: deque ( queue -- elt )
    dup queue-empty? [
        empty-queue-error
    ] [
        dup queue-head entry-obj >r (deque) r>
    ] if ;

M: empty-queue-error summary
    drop "Empty queue" ;

: queue-each ( queue quot -- )
    over queue-empty?
    [ 2drop ] [ [ >r deque r> call ] 2keep queue-each ] if ;
    inline

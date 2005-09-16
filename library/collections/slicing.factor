! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel kernel-internals lists math namespaces
strings vectors ;

: head-slice ( n seq -- slice ) 0 -rot <slice> ; flushable

: tail-slice ( n seq -- slice ) [ length ] keep <slice> ; flushable

: (slice*) [ length swap - ] keep ;

: head-slice* ( n seq -- slice ) (slice*) head-slice ; flushable

: tail-slice* ( n seq -- slice ) (slice*) tail-slice ; flushable

: subseq ( from to seq -- seq ) [ <slice> ] keep like ; flushable

M: object head ( index seq -- seq ) [ head-slice ] keep like ;

: head* ( n seq -- seq ) [ head-slice* ] keep like ; flushable

M: object tail ( index seq -- seq ) [ tail-slice ] keep like ;

: tail* ( n seq -- seq ) [ tail-slice* ] keep like ; flushable

: head? ( seq begin -- ? )
    2dup [ length ] 2apply < [
        2drop f
    ] [
        dup length rot head-slice sequence=
    ] ifte ; flushable

: ?head ( seq begin -- str ? )
    2dup head? [ length swap tail t ] [ drop f ] ifte ; flushable

: tail? ( seq end -- ? )
    2dup [ length ] 2apply < [
        2drop f
    ] [
        dup length rot tail-slice* sequence=
    ] ifte ; flushable

: ?tail ( seq end -- seq ? )
    2dup tail? [ length swap head* t ] [ drop f ] ifte ; flushable

: (group) ( n seq -- )
    2dup length >= [
        dup like , drop
    ] [
        2dup head , dupd tail-slice (group)
    ] ifte ;

: group ( n seq -- seq ) [ (group) ] { } make ; flushable

: start-step ( subseq seq n -- subseq slice )
    pick length dupd + rot <slice> ;

: start* ( subseq seq n -- n )
    pick length pick length pick - > [
        3drop -1
    ] [
        2dup >r >r start-step dupd sequence= [
            r> 2drop r>
        ] [
            r> r> 1 + start*
        ] ifte
    ] ifte ; flushable

: start ( subseq seq -- n )
    #! The index of a subsequence in a sequence.
    0 start* ; flushable

: subseq? ( subseq seq -- ? ) start -1 > ; flushable

: (split1) ( seq subseq -- before after )
    #! After is a slice.
    dup pick start dup -1 = [
        2drop dup like f
    ] [
        [ swap length + over tail-slice ] keep rot head swap
    ] ifte ; flushable

: split1 ( seq subseq -- before after )
    #! After is of the same type as seq.
    (split1) dup like ; flushable

: (split) ( seq subseq -- )
    tuck (split1) >r , r> dup [ swap (split) ] [ 2drop ] ifte ;

: split ( seq subseq -- seq ) [ (split) ] [ ] make ; flushable

: (cut) ( n seq -- ) [ head ] 2keep tail-slice ; flushable

: cut ( n seq -- ) [ (cut) ] keep like ; flushable

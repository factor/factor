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

: length< ( seq seq -- ? ) swap length swap length < ; flushable

: head? ( seq begin -- ? )
    2dup length< [
        2drop f
    ] [
        dup length rot head-slice sequence=
    ] ifte ; flushable

: ?head ( seq begin -- str ? )
    2dup head? [ length swap tail t ] [ drop f ] ifte ; flushable

: tail? ( seq end -- ? )
    2dup length< [
        2drop f
    ] [
        dup length rot tail-slice* sequence=
    ] ifte ; flushable

: ?tail ( seq end -- seq ? )
    2dup tail? [ length swap head* t ] [ drop f ] ifte ; flushable

: group-advance subseq , >r tuck + swap r> ;

: group-finish nip dup length swap subseq , ;

: (group) ( start n seq -- )
    3dup >r dupd + r> 2dup length < [
        group-advance (group)
    ] [
        group-finish 3drop
    ] ifte ;

: group ( n seq -- list )
    #! Split a sequence into element chunks.
    [ 0 -rot (group) ] { } make ; flushable

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

: split1 ( seq subseq -- before after )
    dup pick start dup -1 = [
        2drop f
    ] [
        [ swap length + over tail ] keep rot head swap
    ] ifte ; flushable

: split-next ( index seq subseq -- next )
    pick >r dup pick r> start* dup -1 = [
        >r drop tail , r> ( end of sequence )
    ] [
        swap length dupd + >r swap subseq , r>
    ] ifte ;

: (split) ( index seq subseq -- )
    2dup >r >r split-next dup -1 = [
        r> r> 3drop
    ] [
        r> r> (split)
    ] ifte ;

: split ( seq subseq -- list )
    #! Split the sequence at each occurrence of subseq, and push
    #! a list of the pieces.
    [ 0 -rot (split) ] [ ] make ; flushable

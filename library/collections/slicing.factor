! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel kernel-internals lists math namespaces
strings vectors ;

: head-slice ( n seq -- slice )
    #! n is an index from the start of the sequence.
    0 -rot <slice> ;

: head-slice* ( n seq -- slice )
    #! n is an index from the end of the sequence.
    [ length swap - ] keep head-slice ;

: tail-slice ( n seq -- slice )
    #! n is an index from the start of the sequence.
    [ length ] keep <slice> ;

: tail-slice* ( n seq -- slice )
    #! n is an index from the end of the sequence.
    [ length swap - ] keep tail-slice ;

: subseq ( from to seq -- seq )
    #! Makes a new sequence with the same contents and type as
    #! the slice of another sequence.
    [ <slice> ] keep like ;

M: object head ( index seq -- seq )
    [ head-slice ] keep like ;

: head* ( n seq -- seq )
    [ head-slice* ] keep like ;

M: object tail ( index seq -- seq )
    [ tail-slice ] keep like ;

: tail* ( n seq -- seq )
    [ tail-slice* ] keep like ;

: length< ( seq seq -- ? )
    swap length swap length < ;

: head? ( seq begin -- ? )
    2dup length< [
        2drop f
    ] [
        dup length rot head-slice sequence=
    ] ifte ;

: ?head ( seq begin -- str ? )
    2dup head? [ length swap tail t ] [ drop f ] ifte ;

: tail? ( seq end -- ? )
    2dup length< [
        2drop f
    ] [
        dup length rot tail-slice* sequence=
    ] ifte ;

: ?tail ( seq end -- seq ? )
    2dup tail? [ length swap head* t ] [ drop f ] ifte ;

: cut ( index seq -- seq seq )
    #! Returns 2 sequences, that when concatenated yield the
    #! original sequence.
    [ head ] 2keep tail ;

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
    [ 0 -rot (group) ] make-list ;

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
    ] ifte ;

: start ( subseq seq -- n )
    #! The index of a subsequence in a sequence.
    0 start* ;

: subseq? ( subseq seq -- ? ) start -1 > ;

: split1 ( seq subseq -- before after )
    dup pick start dup -1 = [
        2drop f
    ] [
        [ swap length + over tail ] keep rot head swap
    ] ifte ;

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
    [ 0 -rot (split) ] make-list ;

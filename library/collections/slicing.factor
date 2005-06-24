! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel kernel-internals lists math namespaces
strings vectors ;

! A range of integers.
TUPLE: range from to step ;

C: range ( from to -- range )
    >r 2dup > -1 1 ? r>
    [ set-range-step ] keep
    [ set-range-to ] keep
    [ set-range-from ] keep ;

M: range length ( range -- n )
    dup range-to swap range-from - abs ;

M: range nth ( n range -- n )
    [ range-step * ] keep range-from + ;

M: range like ( seq range -- range )
    drop >vector ;

M: range thaw ( range -- seq )
    >vector ;

! A slice of another sequence.
TUPLE: slice seq ;

C: slice ( from to seq -- )
    [ set-slice-seq ] keep
    [ >r <range> r> set-delegate ] keep ;

M: slice nth ( n slice -- obj )
    [ delegate nth ] keep slice-seq nth ;

M: slice set-nth ( obj n slice -- )
    [ delegate nth ] keep slice-seq set-nth ;

M: slice like ( seq slice -- seq )
    slice-seq like ;

M: slice thaw ( slice -- seq )
    >vector ;

: head-slice ( n seq -- slice )
    0 -rot <slice> ;

: tail-slice ( n seq -- slice )
    [ length ] keep <slice> ;

: tail-slice* ( n seq -- slice )
    [ length swap - ] keep tail-slice ;

: subseq ( from to seq -- seq )
    #! Makes a new sequence with the same contents and type as
    #! the slice of another sequence.
    [ <slice> ] keep like ;

M: object head ( index seq -- seq )
    0 -rot subseq ;

M: object tail ( index seq -- seq )
    #! Returns a new string, from the given index until the end
    #! of the string.
    [ length ] keep subseq ;

: tail* ( n seq -- seq )
    #! Unlike tail, n is an index from the end of the
    #! sequence. For example, if n=1, this returns a sequence of
    #! one element.
    [ length swap - ] keep tail ;

: length< ( seq seq -- ? )
    swap length swap length < ;

: head? ( seq begin -- ? )
    2dup length< [
        2drop f
    ] [
        dup length rot head-slice sequence=
    ] ifte ;

: ?head ( seq begin -- str ? )
    2dup head? [
        length swap tail t
    ] [
        drop f
    ] ifte ;

: tail? ( seq end -- ? )
    2dup length< [
        2drop f
    ] [
        dup length pick length swap - rot tail-slice sequence=
    ] ifte ;

: ?tail ( seq end -- seq ? )
    2dup tail? [
        length swap [ length swap - ] keep head t
    ] [
        drop f
    ] ifte ;

: cut ( index seq -- seq seq )
    #! Returns 2 sequences, that when concatenated yield the
    #! original sequence.
    [ head ] 2keep tail ;

: cut* ( index seq -- seq seq )
    #! Returns 2 sequences, that when concatenated yield the
    #! original sequences, without the element at the given
    #! index.
    [ head ] 2keep >r 1 + r> tail ;

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

! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences-internals
USING: errors generic kernel kernel-internals lists math
sequences strings vectors words ;

: (lexi) ( seq seq i limit -- n )
    2dup >= [
        2drop [ length ] 2apply -
    ] [
        >r 3dup 2nth-unsafe 2dup = [
            2drop 1+ r> (lexi)
        ] [
            r> drop - >r 3drop r>
        ] ifte
    ] ifte ; flushable

IN: sequences

M: object like drop ;

M: object empty? ( seq -- ? ) length 0 = ;

: (>list) ( n i seq -- list )
    pick pick <= [
        3drop [ ]
    ] [
        2dup nth >r >r 1+ r> (>list) r> swons
    ] ifte ;

M: object >list ( seq -- list ) dup length 0 rot (>list) ;

: index   ( obj seq -- n )     [ = ] find-with drop ; flushable
: index*  ( obj i seq -- n )   [ = ] find-with* drop ; flushable
: member? ( obj seq -- ? )     [ = ] contains-with? ; flushable
: memq?   ( obj seq -- ? )     [ eq? ] contains-with? ; flushable
: remove  ( obj list -- list ) [ = not ] subset-with ; flushable

: remove-all ( seq1 seq2 -- seq2-seq1 )
    [ swap member? not ] subset-with ; flushable

: move ( to from seq -- )
    pick pick number=
    [ 3drop ] [ [ nth swap ] keep set-nth ] ifte ; inline

: (delete) ( elt store scan seq -- )
    2dup length < [
        3dup move
        >r pick over r> dup >r nth = r> swap
        [ >r >r 1+ r> r> ] unless >r 1+ r> (delete)
    ] when ;

: delete ( elt seq -- )
    #! Delete all occurrences of elt from seq.
    0 0 rot (delete) nip set-length drop ;

: copy-into-check ( start to from -- )
    rot rot length + swap length < [
        "Cannot copy beyond end of sequence" throw
    ] when ;

: copy-into ( start to from -- )
    #! Copy all elements in 'from' to 'to', storing at
    #! consecutive indices numbered from 'start'.
    3dup copy-into-check
    dup length [ >r pick r> + pick set-nth-unsafe ] 2each 2drop ;

: nappend ( to from -- )
    #! Add all elements of 'from' at the end of 'to'.
    >r dup length swap r>
    over length over length + pick set-length
    copy-into ;

: append ( s1 s2 -- s1+s2 )
    #! Outputs a new sequence of the same type as s1.
    swap [ swap nappend ] immutable ; flushable

: add ( seq elt -- seq )
    #! Outputs a new sequence of the same type as seq.
    swap [ push ] immutable ; flushable

: append3 ( s1 s2 s3 -- s1+s2+s3 )
    #! Return a new sequence of the same type as s1.
    rot [ [ rot nappend ] keep swap nappend ] immutable ; flushable

: concat ( seq -- seq )
    #! Append a sequence of sequences together. The new sequence
    #! has the same type as the first sequence.
    dup empty? [
        [ 1024 <vector> swap [ dupd nappend ] each ] keep
        first like
    ] unless ; flushable

M: object peek ( sequence -- element )
    #! Get value at end of sequence.
    dup length 1- swap nth ;

: pop* ( sequence -- )
    #! Shorten the sequence by one element.
    dup length 1- swap set-length ;

: pop ( sequence -- element )
    #! Get value at end of sequence and remove it.
    dup peek swap pop* ;

: adjoin ( elt seq -- )
    2dup member? [ 2drop ] [ push ] ifte ;

: prune ( seq -- seq )
    [
        dup length <vector> swap [ over adjoin ] each
    ] keep like ; flushable

: join ( seq glue -- seq )
    #! The new sequence is of the same type as glue.
    swap dup empty? [
        swap like
    ] [
        dup length <vector> swap
        [ over push 2dup push ] each nip dup pop*
        concat
    ] ifte ; flushable

M: object reverse-slice ( seq -- seq ) <reversed> ;

M: object reverse ( seq -- seq ) [ <reversed> ] keep like ;

! Lexicographic comparison
: lexi ( s1 s2 -- n )
    #! Lexicographically compare two sequences of numbers
    #! (usually strings). Negative if s1<s2, zero if s1=s2,
    #! positive if s1>s2.
    0 pick pick min-length (lexi) ; flushable

: flip ( seq -- seq )
    #! An example illustrates this word best:
    #! { { 1 2 3 } { 4 5 6 } } ==> { { 1 4 } { 2 5 } { 3 6 } }
    dup empty? [
        dup first [ length ] keep like
        [ swap [ nth ] map-with ] map-with
    ] unless ; flushable

: max-length ( seq -- n )
    #! Longest sequence length in a sequence of sequences.
    0 [ length max ] reduce ; flushable

IN: kernel

: depth ( -- n )
    #! Push the number of elements on the datastack.
    datastack length ;

: no-cond "cond fall-through" throw ; inline

: cond ( conditions -- )
    #! Conditions is a sequence of quotation pairs.
    #! { { [ X ] [ Y ] } { [ Z ] [ T ] } }
    #! => X [ Y ] [ Z [ T ] [ ] ifte ] ifte
    #! The last condition should be a catch-all 't'.
    [ first call ] find nip dup
    [ second call ] [ no-cond ] ifte ;

: with-datastack ( stack word -- stack )
    datastack >r >r set-datastack r> execute
    datastack r> [ push ] keep set-datastack 2nip ;

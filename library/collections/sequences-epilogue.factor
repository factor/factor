! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: errors generic kernel kernel-internals lists math strings
vectors words ;

! Combinators
M: object each ( seq quot -- )
    swap dup length [
        [ swap nth swap call ] 3keep
    ] repeat 2drop ;

: map ( seq quot -- seq | quot: elt -- elt )
    over [
        length <vector> rot
        [ -rot [ slip push ] 2keep ] each nip
    ] keep like ; inline

: map-with ( obj list quot -- list | quot: obj elt -- elt )
    swap [ with rot ] map 2nip ; inline

: accumulate ( list identity quot -- values | quot: x y -- z )
    rot [ pick >r swap call r> ] map-with nip ; inline

: change-nth ( seq i quot -- )
    pick pick >r >r >r swap nth r> call r> r> swap set-nth ;
    inline

: nmap ( seq quot -- seq | quot: elt -- elt )
    over length [ [ swap change-nth ] 3keep ] repeat 2drop ; inline

: 2each ( seq seq quot -- | quot: elt -- )
    over length >r >r cons r> r>
    [ [ swap >r >r uncons r> 2nth r> call ] 3keep ] repeat
    2drop ; inline

: 2reduce ( seq seq identity quot -- value | quot: e x y -- z )
    >r -rot r> 2each ; inline

: 2map ( seq seq quot -- seq | quot: elt elt -- elt )
    over [
        length <vector> 2swap
        [ 2swap [ slip push ] 2keep ] 2each nip
    ] keep like ; inline

: find* ( i seq quot -- i elt )
    pick pick length >= [
        3drop -1 f
    ] [
        3dup >r >r >r >r nth r> call [
            r> dup r> nth r> drop
        ] [
            r> 1 + r> r> find*
        ] ifte
    ] ifte ; inline

: find-with* ( obj i seq quot -- i elt | quot: elt -- ? )
    -rot [ with rot ] find* 2swap 2drop ; inline

M: object find ( seq quot -- i elt )
    0 -rot find* ;

: contains? ( seq quot -- ? )
    find drop -1 > ; inline

: contains-with? ( obj seq quot -- ? )
    find-with drop -1 > ; inline

: all? ( seq quot -- ? )
    #! ForAll(P in X) <==> !Exists(!P in X)
    swap [ swap call not ] contains-with? not ; inline

: all-with? ( obj seq quot -- ? | quot: elt -- ? )
    swap [ with rot ] all? 2nip ; inline

: subset ( seq quot -- seq | quot: elt -- ? )
    #! all elements for which the quotation returned a value
    #! other than f are collected in a new list.
    swap [
        dup length <vector> -rot [
            rot >r 2dup >r >r swap call [
                r> r> r> [ push ] keep swap
            ] [
                r> r> drop r> swap
            ] ifte
        ] each drop
    ] keep like ; inline

: subset-with ( obj seq quot -- seq | quot: obj elt -- ? )
    swap [ with rot ] subset 2nip ; inline

: (monotonic) ( quot seq i -- ? )
    2dup 1 + swap nth >r swap nth r> rot call ; inline

: monotonic? ( seq quot -- ? | quot: elt elt -- ? )
    #! Eg, { 1 2 3 4 } [ < ] monotonic? ==> t
    #!     { 1 3 2 4 } [ < ] monotonic? ==> f
    swap dup length 1 - [
        pick pick >r >r (monotonic) r> r> rot
    ] all? 2nip ; inline

! Operations
M: object like drop ;

M: object empty? ( seq -- ? ) length 0 = ;

: (>list) ( n i seq -- list )
    pick pick <= [
        3drop [ ]
    ] [
        2dup nth >r >r 1 + r> (>list) r> swons
    ] ifte ;

M: object >list ( seq -- list ) dup length 0 rot (>list) ;

: index   ( obj seq -- n )     [ = ] find-with drop ; flushable
: index*  ( obj i seq -- n )   [ = ] find-with* drop ; flushable
: member? ( obj seq -- ? )     [ = ] contains-with? ; flushable
: memq?   ( obj seq -- ? )     [ eq? ] contains-with? ; flushable
: remove  ( obj list -- list ) [ = not ] subset-with ; flushable

: copy-into ( start to from -- )
    dup length [ >r pick r> + pick set-nth ] 2each 2drop ;

: nappend ( to from -- )
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
    dup length 1 - swap nth ;

: pop ( sequence -- element )
    #! Get value at end of sequence and remove it.
    dup peek >r dup length 1 - swap set-length r> ;

: push-new ( elt seq -- )
    2dup member? [ 2drop ] [ push ] ifte ;

: prune ( seq -- seq )
    [
        dup length <vector> swap [ over push-new ] each
    ] keep like ; flushable

: >pop> ( stack -- stack ) dup pop drop ;

: join ( seq glue -- seq )
    #! The new sequence is of the same type as glue.
    swap dup empty? [
        swap like
    ] [
        dup length <vector> swap
        [ over push 2dup push ] each nip >pop>
        concat
    ] ifte ; flushable

M: object reverse-slice ( seq -- seq ) <reversed> ;

M: object reverse ( seq -- seq ) [ <reversed> ] keep like ;

! Set theoretic operations
: seq-intersect ( seq1 seq2 -- seq1/\seq2 )
    [ swap member? ] subset-with ; flushable

: seq-diff ( seq1 seq2 -- seq2-seq1 )
    [ swap member? not ] subset-with ; flushable

: seq-union ( seq1 seq2 -- seq1\/seq2 )
    append prune ; flushable

: contained? ( seq1 seq2 -- ? )
    #! Is every element of seq1 in seq2
    swap [ swap member? ] all-with? ; flushable

! Lexicographic comparison
: (lexi) ( seq seq i limit -- n )
    2dup >= [
        2drop swap length swap length -
    ] [
        >r 3dup 2nth 2dup = [
            2drop 1 + r> (lexi)
        ] [
            r> drop - >r 3drop r>
        ] ifte
    ] ifte ; flushable

: lexi ( s1 s2 -- n )
    #! Lexicographically compare two sequences of numbers
    #! (usually strings). Negative if s1<s2, zero if s1=s2,
    #! positive if s1>s2.
    0 pick length pick length min (lexi) ; flushable

: flip ( seq -- seq )
    #! An example illustrates this word best:
    #! { { 1 2 3 } { 4 5 6 } } ==> { { 1 4 } { 2 5 } { 3 6 } }
    dup empty? [
        dup first length [ swap [ nth ] map-with ] map-with
    ] unless ; flushable

: max-length ( seq -- n )
    #! Longest sequence length in a sequence of sequences.
    0 [ length max ] reduce ; flushable

: exchange ( n n seq -- )
    [ tuck nth >r nth r> ] 3keep tuck
    >r >r set-nth r> r> set-nth ;

: midpoint@ length 2 /i ; inline

: midpoint [ midpoint@ ] keep nth ; inline

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

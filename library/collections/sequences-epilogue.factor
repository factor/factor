! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel kernel-internals lists math strings
vectors ;

! A reversal of an underlying sequence.
TUPLE: reversed ;
C: reversed [ set-delegate ] keep ;
: reversed@ delegate [ length swap - 1 - ] keep ;
M: reversed nth ( n seq -- elt ) reversed@ nth ;
M: reversed set-nth ( elt n seq -- ) reversed@ set-nth ;
M: reversed thaw ( seq -- seq ) delegate reverse ;

! A repeated sequence is the same element n times.
TUPLE: repeated length object ;
M: repeated length repeated-length ;
M: repeated nth nip repeated-object ;

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

: 2map ( seq seq quot -- seq | quot: elt elt -- elt )
    over [
        length <vector> 2swap
        [ 2swap [ slip push ] 2keep ] 2each nip
    ] keep like ; inline

M: object find* ( i seq quot -- i elt  )
    pick pick length >= [
        3drop -1 f
    ] [
        3dup >r >r >r >r nth r> call [
            r> dup r> nth r> drop
        ] [
            r> 1 + r> r> find*
        ] ifte
    ] ifte ;

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

: fiber? ( seq quot -- ? | quot: elt elt -- ? )
    #! Tests if all elements are equivalent under the relation.
    over empty?
    [ 2drop t ] [ >r [ first ] keep r> all-with? ] ifte ; inline

! Operations
M: object thaw clone ;

M: object like drop ;

M: object empty? ( seq -- ? ) length 0 = ;

: (>list) ( n i seq -- list )
    pick pick <= [
        3drop [ ]
    ] [
        2dup nth >r >r 1 + r> (>list) r> swons
    ] ifte ;

M: object >list ( seq -- list ) dup length 0 rot (>list) ;

: index   ( obj seq -- n )     [ = ] find-with drop ;
: indq    ( obj seq -- n )     [ eq? ] find-with drop ;
: index*  ( obj i seq -- n )   [ = ] find-with* drop ;
: indq*   ( obj i seq -- n )   [ eq? ] find-with* drop ;
: member? ( obj seq -- ? )     [ = ] contains-with? ;
: memq?   ( obj seq -- ? )     [ eq? ] contains-with? ;
: remove  ( obj list -- list ) [ = not ] subset-with ;
: remq    ( obj list -- list ) [ eq? not ] subset-with ;

: nappend ( s1 s2 -- )
    #! Destructively append s2 to s1.
    [ over push ] each drop ;

: append ( s1 s2 -- s1+s2 )
    #! Outputs a new sequence of the same type as s1.
    swap [ swap nappend ] immutable ;

: add ( seq elt -- seq )
    #! Outputs a new sequence of the same type as seq.
    swap [ push ] immutable ;

: append3 ( s1 s2 s3 -- s1+s2+s3 )
    #! Return a new sequence of the same type as s1.
    rot [ [ rot nappend ] keep swap nappend ] immutable ;

: concat ( seq -- seq )
    #! Append a sequence of sequences together. The new sequence
    #! has the same type as the first sequence.
    dup empty? [
        [ 1024 <vector> swap [ dupd nappend ] each ] keep
        first like
    ] unless ;

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
    ] keep like ;

: >pop> ( stack -- stack ) dup pop drop ;

: join ( seq glue -- seq )
    #! The new sequence is of the same type as glue.
    swap dup empty? [
        swap like
    ] [
        dup length <vector> swap
        [ over push 2dup push ] each nip >pop>
        concat
    ] ifte ;

M: object reverse-slice ( seq -- seq ) <reversed> ;

M: object reverse ( seq -- seq ) [ <reversed> ] keep like ;

! Set theoretic operations
: seq-intersect ( seq1 seq2 -- seq1/\seq2 )
    [ swap member? ] subset-with ;

: seq-diff ( seq1 seq2 -- seq2-seq1 )
    [ swap member? not ] subset-with ;

: seq-diffq ( seq1 seq2 -- seq2-seq1 )
    [ swap memq? not ] subset-with ;

: seq-union ( seq1 seq2 -- seq1\/seq2 )
    append prune ;

: contained? ( seq1 seq2 -- ? )
    #! Is every element of seq1 in seq2
    swap [ swap member? ] all-with? ;

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
    ] ifte ;

: lexi ( s1 s2 -- n )
    #! Lexicographically compare two sequences of numbers
    #! (usually strings). Negative if s1<s2, zero if s1=s2,
    #! positive if s1>s2.
    0 pick length pick length min (lexi) ;

: lexi> ( seq seq -- ? )
    #! Test if the first sequence follows the second
    #! lexicographically.
    lexi 0 > ;

: seq-transpose ( seq -- seq )
    #! An example illustrates this word best:
    #! { { 1 2 3 } { 4 5 6 } } ==> { { 1 2 } { 3 4 } { 5 6 } }
    dup empty? [
        dup first length [ swap [ nth ] map-with ] map-with
    ] unless ;

: max-length ( seq -- n )
    #! Longest sequence length in a sequence of sequences.
    0 [ length max ] reduce ;

: subst ( new old seq -- seq )
    #! Substitute elements of old in seq with corresponding
    #! elements from new.
    [
        dup pick indq dup -1 = [ drop ] [ nip pick nth ] ifte
    ] map 2nip ;

: copy-into ( to from -- )
    dup length [ pick set-nth ] 2each drop ;

IN: kernel

: depth ( -- n )
    #! Push the number of elements on the datastack.
    datastack length ;

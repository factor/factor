! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel kernel-internals lists math strings
vectors ;

! This is loaded once everything else is available.

! Note that the sequence union does not include lists, or user
! defined tuples that respond to the sequence protocol.
UNION: sequence array string sbuf vector ;

M: object ensure-capacity 2drop ;
M: object thaw clone ;
M: object freeze drop ;

M: object empty? ( seq -- ? ) length 0 = ;

: (>list) ( n i seq -- list )
    pick pick <= [
        3drop [ ]
    ] [
        2dup nth >r >r 1 + r> (>list) r> swons
    ] ifte ;

M: object >list ( seq -- list ) dup length 0 rot (>list) ;
M: general-list >list ( list -- list ) ;

: 2nth ( s s n -- x x ) tuck swap nth >r swap nth r> ;

! Combinators
GENERIC: (seq-each) ( quot seq -- ) inline

M: object (seq-each) ( quot seq -- )
    dup length [
        3dup >r >r >r swap nth swap call r> r> r>
    ] repeat 2drop ;

M: general-list (seq-each) ( quot seq -- )
    swap each ;

: seq-each ( seq quot -- ) swap (seq-each) ; inline

: seq-each-with ( obj seq quot -- )
    swap [ with ] seq-each 2drop ; inline

GENERIC: (tree-each) ( quot obj -- ) inline

M: object (tree-each) swap call ;

M: cons (tree-each) [ car (tree-each) ] 2keep cdr (tree-each) ;

M: f (tree-each) swap call ;

M: sequence (tree-each) [ (tree-each) ] seq-each-with ;

: tree-each swap (tree-each) ; inline

: tree-each-with ( obj vector quot -- )
    swap [ with ] tree-each 2drop ; inline

: change-nth ( seq i quot -- )
    pick pick >r >r >r swap nth r> call r> r> swap set-nth ;

: (nmap) ( seq i quot -- )
    pick length pick <= [
        3drop
    ] [
        3dup >r >r >r change-nth r> r> 1 + r> (nmap)
    ] ifte ; inline

: nmap ( seq quot -- | quot: elt -- elt )
    #! Destructive on seq.
    0 swap (nmap) ; inline

: immutable ( seq quot -- seq | quot: seq -- )
    swap [ thaw ] keep >r dup >r swap call r> r> freeze ; inline

: seq-map ( seq quot -- seq | quot: elt -- elt )
    swap [ swap nmap ] immutable ; inline

: seq-map-with ( obj list quot -- list )
    swap [ with rot ] seq-map 2nip ; inline

: (2nmap) ( seq1 seq2 i quot -- elt3 )
    pick pick >r >r >r 2nth r> call r> r> swap set-nth ; inline

: 2nmap ( seq1 seq2 quot -- | quot: elt1 elt2 -- elt3 )
    #! Destructive on seq2.
    over length [
        [ >r 3dup r> swap (2nmap) ] keep
    ] repeat 3drop ; inline

: seq-2map ( seq1 seq2 quot -- seq | quot: elt1 elt2 -- elt3 )
    swap [ swap 2nmap ] immutable ; inline

! Operations
: index* ( obj i seq -- n )
    #! The index of the object in the sequence, starting from i.
    2dup length >= [
        3drop -1
    ] [
        3dup nth = [ drop nip ] [ >r 1 + r> index* ] ifte
    ] ifte ;

: index ( obj seq -- n )
    #! The index of the object in the sequence.
    0 swap index* ;

: push ( element sequence -- )
    #! Push a value on the end of a sequence.
    dup length swap set-nth ;

: nappend ( s1 s2 -- )
    #! Destructively append s2 to s1.
   ! over length over ensure-capacity
    [ over push ] seq-each drop ;

: append ( s1 s2 -- s1+s2 )
    #! Return a new sequence of the same type as s1.
    swap [ swap nappend ] immutable ;

: append3 ( s1 s2 s3 -- s1+s2+s3 )
    #! Return a new sequence of the same type as s1.
    rot [ [ rot nappend ] keep swap nappend ] immutable ;

: concat ( seq -- seq )
    #! Append together a sequence of sequences.
    dup empty? [
        unswons [ swap [ nappend ] seq-each-with ] immutable
    ] unless ;

M: object peek ( sequence -- element )
    #! Get value at end of sequence.
    dup length 1 - swap nth ;

: pop ( sequence -- element )
    #! Get value at end of sequence and remove it.
    dup peek >r dup length 1 - swap set-length r> ;

: >pop> ( stack -- stack ) dup pop drop ;

: (exchange) ( seq i j -- seq[i] j seq )
    pick >r >r swap nth r> r> ;

: exchange ( seq i j -- )
    #! Exchange seq[i] and seq[j].
    3dup >r >r >r (exchange) r> r> r>
    swap (exchange) set-nth set-nth ;

: (nreverse) ( seq i -- )
    #! Swap seq[i] with seq[length-i-1].
    over length over - 1 - exchange ;

: nreverse ( seq -- )
    #! Destructively reverse seq.
    dup length 2 /i [ 2dup (nreverse) ] repeat drop ;

M: object reverse ( seq -- seq ) [ nreverse ] immutable ;

! Equality testing
: length= ( seq seq -- ? ) length swap length number= ;

: (sequence=) ( seq seq i -- ? )
    over length over number= [
        3drop t
    ] [
        3dup 2nth = [
            1 + (sequence=)
        ] [
            3drop f
        ] ifte
    ] ifte ;

: sequence= ( seq seq -- ? )
    #! Check if two sequences have the same length and elements,
    #! but not necessarily the same class.
    2dup length= [ 0 (sequence=) ] [ 2drop f ] ifte ;

M: sequence = ( obj seq -- ? )
    2dup eq? [
        2drop t
    ] [
        over type over type eq? [
            sequence=
        ] [
            2drop f
        ] ifte
    ] ifte ;

! A repeated sequence is the same element n times.
TUPLE: repeated length object ;
M: repeated length repeated-length ;
M: repeated nth nip repeated-object ;

IN: kernel

: depth ( -- n )
    #! Push the number of elements on the datastack.
    datastack length ;

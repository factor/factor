! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel kernel-internals lists math strings
vectors ;

! This is loaded once everything else is available.
UNION: sequence array general-list string sbuf tuple vector ;

: (>list) ( n i seq -- list )
    pick pick <= [
        3drop [ ]
    ] [
        2dup nth >r >r 1 + r> (>list) r> swons
    ] ifte ;

M: object >list ( seq -- list ) dup length 0 rot (>list) ;
M: general-list >list ( list -- list ) ;

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
M: sequence (tree-each) [ swap call ] seq-each-with ;
: tree-each swap (tree-each) ; inline
: tree-each-with ( obj vector quot -- )
    swap [ with ] tree-each 2drop ; inline

: 2nth ( s s n -- x x ) tuck swap nth >r swap nth r> ;

: (seq-2nmap) ( seq1 seq2 i quot -- elt3 )
    pick pick >r >r >r 2nth r> call r> r> swap set-nth ; inline

: seq-2nmap ( seq1 seq2 quot -- | quot: elt1 elt2 -- elt3 )
    #! Destructive on seq2.
    over length [
        [ >r 3dup r> swap (seq-2nmap) ] keep
    ] repeat 3drop ; inline

: seq-2map ( seq1 seq2 quot -- seq | quot: elt1 elt2 -- elt3 )
    >r clone r> over >r seq-2nmap r> ; inline

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

: seq-append ( s1 s2 -- )
    #! Destructively append s2 to s1.
    [ over push ] seq-each drop ;

: peek ( sequence -- element )
    #! Get value at end of sequence.
    dup length 1 - swap nth ;

: pop ( sequence -- element )
    #! Get value at end of sequence and remove it.
    dup peek >r dup length 1 - swap set-length r> ;

: >pop> ( stack -- stack ) dup pop drop ;

: length= ( seq seq -- ? ) length swap length number= ;

M: sequence = ( obj seq -- ? )
    2dup eq? [
        2drop t
    ] [
        over type over type eq? [
            2dup length= [
                swap >list swap >list =
            ] [
                2drop f
            ] ifte
        ] [
            2drop f
        ] ifte
    ] ifte ;

IN: kernel

: depth ( -- n )
    #! Push the number of elements on the datastack.
    datastack length ;

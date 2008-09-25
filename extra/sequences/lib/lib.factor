! Copyright (C) 2007 Slava Pestov, Chris Double, Doug Coleman,
!                    Eduardo Cavazos, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib kernel sequences math namespaces make
assocs random sequences.private shuffle math.functions arrays
math.parser math.private sorting strings ascii macros assocs.lib
quotations hashtables math.order locals generalizations ;
IN: sequences.lib

: each-withn ( seq quot n -- ) nwith each ; inline

: each-with ( seq quot -- ) with each ; inline

: each-with2 ( obj obj list quot -- ) 2 each-withn ; inline

: map-withn ( seq quot n -- newseq ) nwith map ; inline

: map-with ( seq quot -- ) with map ; inline

: map-with2 ( obj obj list quot -- newseq ) 2 map-withn ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: each-percent ( seq quot -- )
  >r
  dup length
  dup [ / ] curry
  [ 1+ ] prepose
  r> compose
  2each ;                       inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reduce* ( seq quot -- result ) [ ] swap map-reduce ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: higher ( a b quot -- c ) [ compare +gt+ eq? ] curry most ; inline

: lower  ( a b quot -- c ) [ compare +lt+ eq? ] curry most ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longer  ( a b -- c ) [ length ] higher ;

: shorter ( a b -- c ) [ length ] lower ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longest ( seq -- item ) [ longer ] reduce* ;

: shortest ( seq -- item ) [ shorter ] reduce* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bigger ( a b -- c ) [ ] higher ;

: smaller ( a b -- c ) [ ] lower ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: biggest ( seq -- item ) [ bigger ] reduce* ;

: smallest ( seq -- item ) [ smaller ] reduce* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: minmax ( seq -- min max )
    #! find the min and max of a seq in one pass
    1/0. -1/0. rot [ tuck max >r min r> ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ,, ( obj -- ) building get peek push ;
: v, ( -- ) V{ } clone , ;
: ,v ( -- ) building get dup peek empty? [ dup pop* ] when drop ;

: (monotonic-split) ( seq quot -- newseq )
    [
        >r dup unclip suffix r>
        v, [ pick ,, call [ v, ] unless ] curry 2each ,v
    ] { } make ;

: monotonic-split ( seq quot -- newseq )
    over empty? [ 2drop { } ] [ (monotonic-split) ] if ;

ERROR: element-not-found ;
: split-around ( seq quot -- before elem after )
    dupd find over [ element-not-found ] unless
    >r cut rest r> swap ; inline

: (map-until) ( quot pred -- quot )
    [ dup ] swap 3compose
    [ [ drop t ] [ , f ] if ] compose [ find 2drop ] curry ;

: map-until ( seq quot pred -- newseq )
    (map-until) { } make ;

: take-while ( seq quot -- newseq )
    [ not ] compose
    [ find drop [ head-slice ] when* ] curry
    [ dup ] prepose keep like ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<PRIVATE
: translate-string ( n alphabet out-len -- seq )
    [ drop /mod ] with map nip  ;

: map-alphabet ( alphabet seq[seq] -- seq[seq] )
    [ [ swap nth ] with map ] with map ;

: exact-number-strings ( n out-len -- seqs )
    [ ^ ] 2keep [ translate-string ] 2curry map ;

: number-strings ( n max-length -- seqs )
    1+ [ exact-number-strings ] with map concat ;
PRIVATE>

: exact-strings ( alphabet length -- seqs )
    >r dup length r> exact-number-strings map-alphabet ;

: strings ( alphabet length -- seqs )
    >r dup length r> number-strings map-alphabet ;

: switches ( seq1 seq -- subseq )
    ! seq1 is a sequence of ones and zeroes
    >r [ length ] keep [ nth 1 = ] curry filter r>
    [ nth ] curry { } map-as ;

: power-set ( seq -- subsets )
    2 over length exact-number-strings swap [ switches ] curry map ;

: ?first ( seq -- first/f ) 0 swap ?nth ; inline
: ?second ( seq -- second/f ) 1 swap ?nth ; inline
: ?third ( seq -- third/f ) 2 swap ?nth ; inline
: ?fourth ( seq -- fourth/f ) 3 swap ?nth ; inline

: ?first2 ( seq -- 1st/f 2nd/f ) dup ?first swap ?second ; inline
: ?first3 ( seq -- 1st/f 2nd/f 3rd/f ) dup ?first2 rot ?third ; inline
: ?first4 ( seq -- 1st/f 2nd/f 3rd/f 4th/f ) dup ?first3 roll ?fourth ; inline

USE: continuations
: ?subseq ( from to seq -- subseq )
    >r >r 0 max r> r>
    [ length tuck min >r min r> ] keep subseq ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<PRIVATE
: (attempt-each-integer) ( i n quot -- result )
    [
        iterate-step roll
        [ 3nip ] [ iterate-next (attempt-each-integer) ] if*
    ] [ 3drop f ] if-iterate? ; inline recursive
PRIVATE>

: attempt-each ( seq quot -- result )
    (each) iterate-prep (attempt-each-integer) ; inline

: ?nth* ( n seq -- elt/f ? )
    2dup bounds-check? [ nth-unsafe t ] [ 2drop f f ] if ; flushable

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: math.ranges
USE: random 
: randomize ( seq -- seq' )
    dup length 1-
    [ dup 1 > ] [
        [ [0,b) random ] keep dup 
        [ rot [ exchange ] keep ] dip 1-
    ] [ drop ] while ;
    


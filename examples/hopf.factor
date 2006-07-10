! Finitely generated Hopf algebras.
! Making this efficient is left as an exercise for the reader.
USING: arrays errors hashtables io kernel math namespaces parser
prettyprint sequences words ;
IN: hopf

! An element is represented as a hashtable mapping basis
! elements to scalars.

! A generator is a pair of arrays, odd/even generators.

! Example:

SYMBOLS: a b c ;

: SYMBOLS:
    string-mode on
    [ string-mode off [ create-in define-symbol ] each ] f ;
    parsing

: canonicalize
    [ nip zero? not ] hash-subset ;

SYMBOL: degrees

H{ } clone degrees set

: deg= degrees get set-hash ;

: deg degrees get hash ;

: <basis-elt> ( generators -- { odd even } )
    V{ } clone V{ } clone
    rot [
        3dup deg odd? [ drop ] [ nip ] if push
    ] each [ >array ] 2apply 2array ;

: >h ( obj -- vec )
    {
        { [ dup not ] [ drop 0 >h ] }
        { [ dup number? ] [ { { } { } } associate ] }
        { [ dup array? ] [ <basis-elt> 1 swap associate ] }
        { [ dup hashtable? ] [ ] }
        { [ t ] [ 1array >h ] }
    } cond ;

: (h+) ( x -- )
    >h [ swap +@ ] hash-each ;

: h+ ( x y -- x+y )
    [ (h+) (h+) ] make-hash canonicalize ;

: hsum ( seq -- vec )
    [ [ (h+) ] each ] make-hash canonicalize ;

: num-h. ( n -- str )
    {
        { [ dup 1 = ] [ drop " + " ] }
        { [ dup -1 = ] [ drop " - " ] }
        { [ t ] [ number>string " + " swap append ] }
    } cond ;

: h. ( vec -- )
    dup hash-empty? [
        drop 0 .
    ] [
        [
            [
                num-h.
                swap concat [ unparse ] map "/\\" join
                append ,
            ] hash-each
        ] { } make concat " + " ?head drop print
    ] if ;

: permutation ( seq -- perm )
    dup natural-sort [ swap index ] map-with ;

: (inversions) ( n seq -- n )
    [ > ] subset-with length ;

: inversions ( seq -- n )
    0 swap dup length [
        swap [ nth ] 2keep >r 1+ r> tail-slice (inversions) +
    ] each-with ;

: -1^ odd? -1 1 ? ;

: duplicates? ( seq -- ? )
    dup prune [ length ] 2apply > ;

: odd/\ ( n terms1 terms2 -- n terms )
    append dup duplicates? [
        2drop 0 { }
    ] [
        dup permutation inversions -1^ rot *
        swap natural-sort
    ] if ;

: even/\ ( terms1 terms2 -- terms )
    append natural-sort ;

: (/\) ( n basis1 basis2 -- n basis )
    [
        [ first ] 2apply odd/\
    ] 2keep [ second ] 2apply even/\ 2array ;

: /\ ( x y -- x/\y )
    [ >h ] 2apply [
        [
            rot [
                2swap [
                    swapd * -rot (/\) +@
                ] 2keep
            ] hash-each 2drop
        ] hash-each-with
    ] make-hash canonicalize ;

SYMBOL: boundaries

H{ } clone boundaries set

: d= ( value basis -- ) boundaries get set-hash ;

: ((d)) ( basis -- value ) boundaries get hash ;

: dx/\y ( x y -- vec ) >r ((d)) r> /\ ;

DEFER: (d)

: x/\dy ( x y -- vec ) [ (d) /\ ] keep [ deg ] map sum -1^ /\ ;

: (d) ( product -- value )
    #! d(x/\y)=dx/\y + (-1)^deg y x/\dy
    dup empty?
    [ drop 0 ] [ unclip swap [ x/\dy ] 2keep dx/\y h+ ] if ;

: d ( x -- dx )
    >h [ [ swap concat (d) /\ , ] hash-each ] { } make hsum ;

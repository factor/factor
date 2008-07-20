! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math sequences vectors math.order
sequences sequences.private math.order ;
IN: sorting

! Optimized merge-sort:
!
! 1) only allocates 2 temporary arrays

! 2) first phase (interchanging pairs x[i], x[i+1] where
! x[i] > x[i+1]) is handled specially

<PRIVATE

TUPLE: merge
{ seq    array }
{ accum  vector }
{ accum1 vector }
{ accum2 vector }
{ from1  array-capacity }
{ to1    array-capacity }
{ from2  array-capacity }
{ to2    array-capacity } ;

: dump ( from to seq accum -- )
    #! Optimize common case where to - from = 1, 2, or 3.
    >r >r 2dup swap - dup 1 =
    [ 2drop r> nth-unsafe r> push ] [
        dup 2 = [
            2drop dup 1+
            r> [ nth-unsafe ] curry bi@
            r> [ push ] curry bi@
        ] [
            dup 3 = [
                2drop dup 1+ dup 1+
                r> [ nth-unsafe ] curry tri@
                r> [ push ] curry tri@
            ] [
                drop r> subseq r> push-all
            ] if
        ] if
    ] if ; inline

: l-elt   [ from1>> ] [ seq>> ] bi nth-unsafe ; inline
: r-elt   [ from2>> ] [ seq>> ] bi nth-unsafe ; inline
: l-done? [ from1>> ] [ to1>> ] bi number= ; inline
: r-done? [ from2>> ] [ to2>> ] bi number= ; inline
: dump-l  [ [ from1>> ] [ to1>> ] [ seq>> ] tri ] [ accum>> ] bi dump ; inline
: dump-r  [ [ from2>> ] [ to2>> ] [ seq>> ] tri ] [ accum>> ] bi dump ; inline
: l-next  [ [ l-elt ] [ [ 1+ ] change-from1 drop ] bi ] [ accum>> ] bi push ; inline
: r-next  [ [ r-elt ] [ [ 1+ ] change-from2 drop ] bi ] [ accum>> ] bi push ; inline
: decide  [ [ l-elt ] [ r-elt ] bi ] dip call +gt+ eq? ; inline

: (merge) ( merge quot: ( elt1 elt2 -- <=> ) -- )
    over r-done? [ drop dump-l ] [
        over l-done? [ drop dump-r ] [
            2dup decide
            [ over r-next ] [ over l-next ] if
            (merge)
        ] if
    ] if ; inline recursive

: flip-accum ( merge -- )
    dup [ accum>> ] [ accum1>> ] bi eq? [
        dup accum1>> underlying>> >>seq
        dup accum2>> >>accum
    ] [
        dup accum1>> >>accum
        dup accum2>> underlying>> >>seq
    ] if
    dup accum>> 0 >>length 2drop ; inline

: <merge> ( seq -- merge )
    \ merge new
        over >vector >>accum1
        swap length <vector> >>accum2
        dup accum1>> underlying>> >>seq
        dup accum2>> >>accum
        dup accum>> 0 >>length drop ; inline

: compute-midpoint ( merge -- merge )
    dup [ from1>> ] [ to2>> ] bi + 2/ >>to1 ; inline

: merging ( from to merge -- )
    swap >>to2
    swap >>from1
    compute-midpoint
    dup [ to1>> ] [ seq>> length ] bi min >>to1
    dup [ to2>> ] [ seq>> length ] bi min >>to2
    dup to1>> >>from2
    drop ; inline

: nth-chunk ( n size -- from to ) [ * dup ] keep + ; inline

: chunks ( length size -- n ) [ align ] keep /i ; inline

: each-chunk ( length size quot -- )
    [ [ chunks ] keep ] dip
    [ nth-chunk ] prepose curry
    each-integer ; inline

: merge ( from to merge quot -- )
    [ [ merging ] keep ] dip (merge) ; inline

: sort-pass ( merge size quot -- )
    [
        over flip-accum
        over [ seq>> length ] 2dip
    ] dip
    [ merge ] 2curry each-chunk ; inline

: sort-loop ( merge quot -- )
    [ 2 [ over seq>> length over > ] ] dip
    [ [ 1 shift 2dup ] dip sort-pass ] curry
    [ ] while 2drop ; inline

: each-pair ( seq quot -- )
    [ [ length 1+ 2/ ] keep ] dip
    [ [ 1 shift dup 1+ ] dip ] prepose curry each-integer ; inline

: (sort-pairs) ( i1 i2 seq quot accum -- )
    >r >r 2dup length = [
        nip nth r> drop r> push
    ] [
        tuck [ nth-unsafe ] 2bi@ 2dup r> call +gt+ eq?
        [ swap ] when r> tuck [ push ] 2bi@
    ] if ; inline

: sort-pairs ( merge quot -- )
    [ [ seq>> ] [ accum>> ] bi ] dip swap
    [ (sort-pairs) ] 2curry each-pair ; inline

PRIVATE>

: sort ( seq quot -- seq' )
    [ <merge> ] dip
    [ sort-pairs ] [ sort-loop ] [ drop accum>> underlying>> ] 2tri ;
    inline

: natural-sort ( seq -- sortedseq ) [ <=> ] sort ;

: sort-keys ( seq -- sortedseq ) [ [ first ] compare ] sort ;

: sort-values ( seq -- sortedseq ) [ [ second ] compare ] sort ;

: sort-pair ( a b -- c d ) 2dup after? [ swap ] when ;

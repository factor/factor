! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math sequences vectors
sequences sequences.private growable ;
IN: sorting

: midpoint@ ( seq -- n ) length 2/ ; inline

DEFER: sort

<PRIVATE

: <iterator> 0 tail-slice ; inline

: this ( slice -- obj )
    dup slice-from swap slice-seq nth-unsafe ; inline

: next ( iterator -- )
    dup slice-from 1+ swap set-slice-from ; inline

: smallest ( iter1 iter2 quot -- elt )
    >r over this over this r> call 0 <
    -rot ? [ this ] keep next ; inline

: (merge) ( iter1 iter2 quot accum -- )
    >r pick empty? [
        drop nip r> push-all
    ] [
        over empty? [
            2drop r> push-all
        ] [
            3dup smallest r> [ push ] keep (merge)
        ] if
    ] if ; inline

: merge ( sorted1 sorted2 quot -- result )
    >r [ [ <iterator> ] 2apply ] 2keep r>
    rot length rot length + <vector>
    [ (merge) ] keep underlying ; inline

: divide ( seq -- first second )
    dup midpoint@ [ head-slice ] 2keep tail-slice ;

: conquer ( first second quot -- result )
    [ tuck >r >r sort r> r> sort ] keep merge ; inline

PRIVATE>

: sort ( seq quot -- sortedseq )
    over length 1 <=
    [ drop ] [ over >r >r divide r> conquer r> like ] if ;
    inline

: natural-sort ( seq -- sortedseq ) [ <=> ] sort ;

: sort-keys ( seq -- sortedseq ) [ [ first ] compare ] sort ;

: sort-values ( seq -- sortedseq ) [ [ second ] compare ] sort ;

: sort-pair ( a b -- c d ) 2dup <=> 0 > [ swap ] when ;

: midpoint ( seq -- elt )
    [ midpoint@ ] keep nth-unsafe ; inline

: partition ( seq n -- slice )
    >r dup midpoint@ r> 1 < [ head-slice ] [ tail-slice ] if ;
    inline

: (binsearch) ( elt quot seq -- i )
    dup length 1 <= [
        slice-from 2nip
    ] [
        [ midpoint swap call ] 3keep roll dup zero?
        [ drop dup slice-from swap midpoint@ + 2nip ]
        [ partition (binsearch) ] if
    ] if ; inline

: binsearch ( elt seq quot -- i )
    swap dup empty?
    [ 3drop f ] [ <flat-slice> (binsearch) ] if ; inline

: binsearch* ( elt seq quot -- result )
    over >r binsearch [ r> ?nth ] [ r> drop f ] if* ; inline

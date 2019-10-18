! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences-internals
USING: arrays generic kernel math sequences vectors ;

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
    [ (merge) ] keep { } like ; inline

: divide ( seq -- first second )
    dup midpoint@ [ head-slice ] 2keep tail-slice ;

IN: sequences

DEFER: sort

IN: sequences-internals

: conquer ( first second quot -- result )
    [ tuck >r >r sort r> r> sort ] keep merge ; inline

IN: sequences

: sort ( seq quot -- result )
    over length 1 <=
    [ drop ] [ over >r >r divide r> conquer r> like ] if ;
    inline

: natural-sort ( seq -- sortedseq ) [ <=> ] sort ;

: sort-keys ( alist -- alist ) [ [ first ] compare ] sort ;

: sort-values ( alist -- alist ) [ [ second ] compare ] sort ;

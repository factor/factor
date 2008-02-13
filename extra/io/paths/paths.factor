USING: arrays assocs combinators.lib dlists io.files
kernel namespaces sequences shuffle vectors ;
IN: io.paths

! HOOK: library-roots io-backend ( -- seq )
! HOOK: binary-roots io-backend ( -- seq )

<PRIVATE
: append-path ( path files -- paths )
    [ >r path+ r> ] with* assoc-map ;

: get-paths ( dir -- paths )
    dup directory append-path ;

: (walk-dir) ( path -- )
    first2 [
        get-paths dup keys % [ (walk-dir) ] each
    ] [
        drop
    ] if ;
PRIVATE>

: walk-dir ( path -- seq )
    dup directory? 2array [ (walk-dir) ] { } make ;

GENERIC# find-file* 1 ( obj quot -- path/f )

M: dlist find-file* ( dlist quot -- path/f )
    over dlist-empty? [ 2drop f ] [
        2dup >r pop-front get-paths dup r> assoc-find
        [ drop 3nip ]
        [ 2drop [ nip ] assoc-subset keys pick push-all-back find-file* ] if
    ] if ;

M: vector find-file* ( vector quot -- path/f )
    over empty? [ 2drop f ] [
        2dup >r pop get-paths dup r> assoc-find
        [ drop 3nip ]
        [ 2drop [ nip ] assoc-subset keys pick push-all find-file* ] if
    ] if ;

: prepare-find-file ( quot -- quot )
    [ drop ] swap compose ;

: find-file-depth ( path quot -- path/f )
    prepare-find-file >r 1vector r> find-file* ;

: find-file-breadth ( path quot -- path/f )
    prepare-find-file >r 1dlist r> find-file* ;

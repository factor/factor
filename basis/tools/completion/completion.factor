! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences math namespaces strings io fry
vectors words assocs combinators sorting unicode.case
unicode.categories math.order ;
IN: tools.completion

: (fuzzy) ( accum ch i full -- accum i ? )
    index-from
    [
        [ swap push ] 2keep 1+ t
    ] [
        drop f -1 f
    ] if* ;

: fuzzy ( full short -- indices )
    dup length <vector> -rot 0 -rot
    [ -rot [ (fuzzy) ] keep swap ] all? 3drop ;

: (runs) ( runs n seq -- runs n )
    [
        [
            2dup number=
            [ drop ] [ nip V{ } clone pick push ] if
            1+
        ] keep pick peek push
    ] each ;

: runs ( seq -- newseq )
    V{ V{ } } [ clone ] map over first rot (runs) drop ;

: score-1 ( i full -- n )
    {
        { [ over zero? ] [ 2drop 10 ] }
        { [ 2dup length 1- number= ] [ 2drop 4 ] }
        { [ 2dup [ 1- ] dip nth Letter? not ] [ 2drop 10 ] }
        { [ 2dup [ 1+ ] dip nth Letter? not ] [ 2drop 4 ] }
        [ 2drop 1 ]
    } cond ;

: score ( full fuzzy -- n )
    dup [
        [ [ length ] bi@ - 15 swap [-] 3 /f ] 2keep
        runs [
            [ 0 [ pick score-1 max ] reduce nip ] keep
            length * +
        ] with each
    ] [
        2drop 0
    ] if ;

: rank-completions ( results -- newresults )
    sort-keys <reversed>
    [ 0 [ first max ] reduce 3 /f ] keep
    [ first < ] with filter
    [ second ] map ;

: complete ( full short -- score )
    [ dupd fuzzy score ] 2keep
    [ <reversed> ] bi@
    dupd fuzzy score max ;

: completion ( short candidate -- result )
    [ second >lower swap complete ] keep 2array ;

: completions ( short candidates -- seq )
    [ '[ _ ] ]
    [ '[ >lower _ [ completion ] with map rank-completions ] ] bi
    if-empty ;

: limited-completions ( short candidates -- seq )
    [ completions ] [ drop ] 2bi
    2dup [ length 50 > ] [ empty? ] bi* and
    [ 2drop f ] [ drop 50 short head ] if ;

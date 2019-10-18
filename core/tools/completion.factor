! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: completion
USING: kernel arrays sequences math namespaces strings io
vectors ;

! Simple fuzzy search.

: (fuzzy) ( accum ch i full -- accum i ? )
    index* dup 0 < [
        2drop f -1 f
    ] [
        [ swap push ] 2keep 1+ t
    ] if ;

: fuzzy ( full short -- indices )
    dup length <vector> 0 2swap
    [ -rot [ (fuzzy) ] keep swap ] all? 3drop ;

: (runs) ( runs n seq -- runs n )
    [
        [
            2dup number=
            [ drop ] [ nip V{ } clone pick push ] if
            1+
        ] keep pick peek push
    ] each ;

: runs ( seq -- seq )
    V{ V{ } } [ clone ] map over first rot (runs) drop ;

: score-1 ( i full -- n )
    {
        { [ over zero? ] [ 2drop 10 ] }
        { [ 2dup length 1- number= ] [ 2drop 4 ] }
        { [ 2dup >r 1- r> nth Letter? not ] [ 2drop 10 ] }
        { [ 2dup >r 1+ r> nth Letter? not ] [ 2drop 4 ] }
        { [ t ] [ 2drop 1 ] }
    } cond ;

: score ( full fuzzy -- n )
    dup [
        [ [ length ] 2apply - 15 swap [-] 3 / ] 2keep
        runs [
            [ 0 [ pick score-1 max ] reduce nip ] keep
            length * +
        ] each-with
    ] [
        2drop 0
    ] if ;

: rank-completions ( results -- newresults )
    #! Discard results in the low 33%
    sort-keys <reversed>
    [ 0 [ first max ] reduce 3 / ] keep
    [ first < ] subset-with
    [ second ] map ;

: complete ( full short -- score )
    #! Match forwards and backwards, see which one has the
    #! highest score.
    [ dupd fuzzy score ] 2keep
    [ <reversed> ] 2apply
    dupd fuzzy score max ;

: completion ( str quot obj -- pair )
    #! pair is { score obj }
    [ swap call swap complete ] keep 2array ; inline

: completions ( str quot candidates -- seq )
    pick empty? [
        2nip
    ] [
        [ >r 2dup r> completion ] map 2nip rank-completions
    ] if ; inline

: string-completions ( str strs -- seq )
    f swap completions ;

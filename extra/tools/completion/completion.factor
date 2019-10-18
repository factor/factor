! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools.completion
USING: kernel arrays sequences math namespaces strings io
vectors words assocs combinators sorting ;

: (fuzzy) ( accum ch i full -- accum i ? )
    index* 
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
        { [ 2dup >r 1- r> nth Letter? not ] [ 2drop 10 ] }
        { [ 2dup >r 1+ r> nth Letter? not ] [ 2drop 4 ] }
        { [ t ] [ 2drop 1 ] }
    } cond ;

: score ( full fuzzy -- n )
    dup [
        [ [ length ] 2apply - 15 swap [-] 3 /f ] 2keep
        runs [
            [ 0 [ pick score-1 max ] reduce nip ] keep
            length * +
        ] curry* each
    ] [
        2drop 0
    ] if ;

: rank-completions ( results -- newresults )
    sort-keys <reversed>
    [ 0 [ first max ] reduce 3 /f ] keep
    [ first < ] curry* subset
    [ second ] map ;

: complete ( full short -- score )
    [ dupd fuzzy score ] 2keep
    [ <reversed> ] 2apply
    dupd fuzzy score max ;

: completion ( short candidate -- result )
    [ second swap complete ] keep first 2array ;

: completions ( short candidates -- seq )
    over empty? [
        nip [ first ] map
    ] [
        >r >lower r> [ completion ] curry* map rank-completions
    ] if ;

: string-completions ( short strs -- seq )
    [ dup ] { } map>assoc completions ;

: limited-completions ( short candidates -- seq )
    completions dup length 1000 > [ drop f ] when ;

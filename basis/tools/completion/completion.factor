! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel arrays sequences math namespaces
strings io fry vectors words assocs combinators sorting
unicode.case unicode.categories math.order vocabs
tools.vocabs unicode.data locals ;
IN: tools.completion

:: (fuzzy) ( accum i full ch -- accum i full ? )
    ch i full index-from [
        :> i i accum push
        accum i 1+ full t
    ] [
        f -1 full f
    ] if* ;

: fuzzy ( full short -- indices )
    dup [ length <vector> 0 ] curry 2dip
    [ (fuzzy) ] all? 3drop ;

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
    [ ] [ [ >lower ] dip [ completion ] with map rank-completions ]
    bi-curry if-empty ;

: name-completions ( str seq -- seq' )
    [ dup name>> ] { } map>assoc completions ;

: words-matching ( str -- seq )
    all-words name-completions ;

: vocabs-matching ( str -- seq )
    all-vocabs-seq name-completions ;

: chars-matching ( str -- seq )
    name-map keys dup zip completions ;
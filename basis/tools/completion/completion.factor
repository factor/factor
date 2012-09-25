! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs colors.constants combinators
combinators.short-circuit fry io io.directories kernel locals
make math math.order namespaces sequences sorting splitting
strings unicode.case unicode.categories unicode.data vectors
vocabs vocabs.hierarchy words ;

IN: tools.completion

<PRIVATE

: smart-index-from ( obj i seq -- n/f )
    rot [ ch>lower ] [ ch>upper ] bi
    '[ dup _ eq? [ drop t ] [ _ eq? ] if ] find-from drop ;

:: (fuzzy) ( accum i full ch -- accum i ? )
    ch i full smart-index-from [
        [ accum push ]
        [ accum swap 1 + t ] bi
    ] [
        f -1 f
    ] if* ;

PRIVATE>

: fuzzy ( full short -- indices )
    dup [ length <vector> 0 ] curry 2dip
    [ (fuzzy) ] with all? 2drop ;

<PRIVATE

: (runs) ( runs n seq -- runs n )
    [
        [
            2dup number=
            [ drop ] [ nip V{ } clone pick push ] if
            1 +
        ] keep pick last push
    ] each ;

PRIVATE>

: runs ( seq -- newseq )
    [ V{ } clone 1vector ] dip [ first ] keep (runs) drop ;

<PRIVATE

: score-1 ( i full -- n )
    {
        { [ over zero? ] [ 2drop 10 ] }
        { [ 2dup length 1 - number= ] [ 2drop 4 ] }
        { [ 2dup [ 1 - ] dip nth Letter? not ] [ 2drop 10 ] }
        { [ 2dup [ 1 + ] dip nth Letter? not ] [ 2drop 4 ] }
        [ 2drop 1 ]
    } cond ;

PRIVATE>

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
    values ;

: complete ( full short -- score )
    [ dupd fuzzy score ] 2keep
    [ <reversed> ] bi@
    dupd fuzzy score max ;

: completion ( short candidate -- result )
    [ second swap complete ] keep 2array ;

: completion, ( short candidate -- )
    completion dup first 0 > [ , ] [ drop ] if ;

: completions ( short candidates -- seq )
    [ ] [
        [ [ completion, ] with each ] { } make
        rank-completions
    ] bi-curry if-empty ;

: name-completions ( str seq -- seq' )
    [ dup name>> ] { } map>assoc completions ;

: words-matching ( str -- seq )
    all-words name-completions ;

: vocabs-matching ( str -- seq )
    all-vocabs-recursive filter-vocabs name-completions ;

: chars-matching ( str -- seq )
    name-map keys dup zip completions ;

: colors-matching ( str -- seq )
    named-colors dup zip completions ;

: paths-matching ( str path -- seq )
    directory-files dup zip completions ;

<PRIVATE

: (complete-single-vocab?) ( str -- ? )
    { "IN:" "USE:" "UNUSE:" "QUALIFIED:" "QUALIFIED-WITH:" }
    member? ; inline

: complete-single-vocab? ( tokens -- ? )
    dup last empty? [
        harvest ?last (complete-single-vocab?)
    ] [
        harvest dup length 1 >
        [ 2 tail* ?first (complete-single-vocab?) ] [ drop f ] if
    ] if ;

: chop-; ( seq -- seq' )
    { ";" } split1-last [ ] [ ] ?if ;

: complete-vocab-list? ( tokens -- ? )
    chop-; 1 short head* "USING:" swap member? ;

PRIVATE>

: complete-vocab? ( tokens -- ? )
    { [ complete-single-vocab? ] [ complete-vocab-list? ] } 1|| ;

: complete-CHAR:? ( tokens -- ? )
    2 short tail* "CHAR:" swap member? ;

: complete-COLOR:? ( tokens -- ? )
    2 short tail* "COLOR:" swap member? ;

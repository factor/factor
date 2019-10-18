! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs colors.constants combinators
combinators.short-circuit fry io.directories io.files
io.files.info io.pathnames kernel locals make math math.order
sequences sequences.private sorting splitting
splitting.monotonic unicode unicode.data vectors vocabs
vocabs.hierarchy ;
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
    ] if* ; inline

PRIVATE>

: fuzzy ( full short -- indices )
    dup [ length <vector> 0 ] curry 2dip
    [ (fuzzy) ] with all? 2drop ;

: runs ( seq -- newseq )
    [ 1 - = ] monotonic-split-slice ;

<PRIVATE

: score-1 ( i full -- n )
    {
        { [ over zero? ] [ 2drop 10 ] }
        { [ 2dup length 1 - number= ] [ 2drop 4 ] }
        { [ 2dup [ 1 - ] dip nth-unsafe Letter? not ] [ 2drop 10 ] }
        { [ 2dup [ 1 + ] dip nth-unsafe Letter? not ] [ 2drop 4 ] }
        [ 2drop 1 ]
    } cond ; inline

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
    [ 0 [ first max ] reduce 3 /f ] keep
    [ first-unsafe < ] with filter
    sort-keys <reversed> values ;

: complete ( full short -- score )
    2dup [ <reversed> ] bi@ [ dupd fuzzy score ] 2bi@ max ;

: completion ( short candidate -- result )
    [ second swap complete ] keep 2array ; inline

: completion, ( short candidate -- )
    completion dup first-unsafe 0 > [ , ] [ drop ] if ;

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
    all-disk-vocabs-recursive filter-vocabs name-completions ;

: vocab-words-matching ( str vocab -- seq )
    vocab-words name-completions ;

: chars-matching ( str -- seq )
    name-map keys dup zip completions ;

: colors-matching ( str -- seq )
    named-colors dup zip completions ;

: strings-matching ( str seq -- seq' )
    dup zip completions keys ;

<PRIVATE

: directory-paths ( directory -- alist )
    dup '[
        [
            [ name>> dup _ prepend-path ]
            [ directory? [ path-separator append ] when ]
            bi swap
        ] { } map>assoc
    ] with-directory-entries ;

PRIVATE>

: paths-matching ( str -- seq )
    dup last-path-separator [ 1 + cut ] [ drop "" ] if swap
    dup { [ exists? ] [ file-info directory? ] } 1&&
    [ directory-paths completions ] [ 2drop { } ] if ;

<PRIVATE

: (complete-single-vocab?) ( str -- ? )
    {
        "IN:" "USE:" "UNUSE:" "QUALIFIED:"
        "QUALIFIED-WITH:" "FROM:" "EXCLUDE:"
    } member? ; inline

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

: complete-vocab-words? ( tokens -- ? )
    harvest chop-; {
        [ length 3 >= ]
        [ first { "FROM:" "EXCLUDE:" } member? ]
        [ third "=>" = ]
    } 1&& ;

<PRIVATE

: complete-token? ( tokens token -- ? )
    over last empty? [
        [ harvest ?last ] [ = ] bi*
    ] [
        swap harvest dup length 1 >
        [ 2 tail* ?first = ] [ 2drop f ] if
    ] if ; inline

PRIVATE>

: complete-char? ( tokens -- ? ) "CHAR:" complete-token? ;

: complete-color? ( tokens -- ? ) "COLOR:" complete-token? ;

: complete-pathname? ( tokens -- ? ) "P\"" complete-token? ;

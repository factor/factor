! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs colors combinators
combinators.short-circuit editors io.directories io.files
io.files.info io.pathnames kernel make math math.order sequences
sequences.private sorting splitting splitting.monotonic unicode
unicode.data vocabs vocabs.hierarchy ;
IN: tools.completion

<PRIVATE

: fuzzy-index-from ( ch i seq -- n/f )
    rot [ ch>lower ] [ ch>upper ] bi
    '[ dup _ eq? [ drop t ] [ _ eq? ] if ] find-from drop ;

:: (fuzzy) ( accum i ch full -- accum i ? )
    ch i full fuzzy-index-from [
        [ accum push ]
        [ accum swap 1 + t ] bi
    ] [
        f f f
    ] if* ; inline

PRIVATE>

: fuzzy ( full short -- indices )
    [ V{ } clone 0 ] 2dip swap '[ _ (fuzzy) ] all? 2drop ;

: runs ( seq -- newseq )
    [ 1 - = ] monotonic-split-slice ;

<PRIVATE

: score-1 ( i full -- n )
    {
        { [ over zero? ] [ 2drop 10 ] }
        { [ 2dup length 1 - = ] [ 2drop 4 ] }
        { [ 2dup [ 1 - ] dip nth-unsafe Letter? not ] [ 2drop 10 ] }
        { [ 2dup [ 1 + ] dip nth-unsafe Letter? not ] [ 2drop 4 ] }
        [ 2drop 1 ]
    } cond ; inline

PRIVATE>

: score ( full fuzzy -- n )
    [
        [ 2length - 15 swap [-] 3 /f ] 2keep
        runs [
            [ 0 [ pick score-1 max ] reduce nip ] keep
            length * +
        ] with each
    ] [
        drop 0
    ] if* ;

: rank-completions ( results -- newresults )
    dup length 25 > [
        [ [ first ] [ max ] map-reduce 4 /f ] keep
        [ first < ] with filter
    ] when sort-keys <reversed> values ;

: complete ( full short -- score )
    [ dupd fuzzy score ] 2keep pick 0 > [
        [ <reversed> ] bi@ dupd fuzzy score max
    ] [ 2drop ] if ;

: completion ( short candidate -- score candidate )
    [ second swap complete ] keep ; inline

: completion, ( short candidate -- )
    completion over 0 > [ 2array , ] [ 2drop ] if ;

: completions ( short candidates -- seq )
    [ ] [
        [ [ completion, ] with each ] { } make
        rank-completions
    ] bi-curry if-empty ;

: named ( seq -- seq' )
    [ dup name>> ] map>alist ;

: vocabs-matching ( str -- seq )
    all-disk-vocabs-recursive filter-vocabs named completions ;

: vocab-words-matching ( str vocab -- seq )
    vocab-words named completions ;

: qualified-named ( str -- seq/f )
    ":" split1 [
        vocabs-matching keys [
            [ vocab-words ] [ vocab-name ] bi ":" append
            [ over name>> append ] curry map>alist
        ] map concat
    ] [ drop f ] if ;

: words-matching ( str -- seq )
    all-words named over qualified-named [ append ] unless-empty completions ;

: chars-matching ( str -- seq )
    name-map keys dup zip completions ;

: colors-matching ( str -- seq )
    named-colors dup zip completions ;

: editors-matching ( str -- seq )
    available-editors [ "editors." ?head drop ] map dup zip completions ;

: strings-matching ( str seq -- seq' )
    dup zip completions keys ;

<PRIVATE

: directory-paths ( directory -- alist )
    dup '[
        [
            [ name>> dup _ prepend-path ]
            [ directory? [ path-separator append ] when ]
            bi swap
        ] map>alist
    ] with-directory-entries ;

PRIVATE>

: paths-matching ( str -- seq )
    "P\"" ?head [
        dup last-path-separator [ 1 + cut ] [ drop "" ] if swap
        dup { [ file-exists? ] [ file-info directory? ] } 1&&
        [ directory-paths completions ] [ 2drop { } ] if
    ] dip [ [ [ "P\"" prepend ] dip ] assoc-map ] when ;

<PRIVATE

: (complete-single-vocab?) ( str -- ? )
    {
        "IN:" "USE:" "UNUSE:" "QUALIFIED:"
        "QUALIFIED-WITH:" "FROM:" "EXCLUDE:"
        "REUSE:"
    } member? ; inline

: complete-single-vocab? ( tokens -- ? )
    dup last empty? [
        harvest ?last (complete-single-vocab?)
    ] [
        harvest dup length 1 >
        [ 2 tail* ?first (complete-single-vocab?) ] [ drop f ] if
    ] if ;

: chop-; ( seq -- seq' )
    { ";" } split1-last swap or ;

: complete-vocab-list? ( tokens -- ? )
    chop-; 1 index-or-length head* "USING:" swap member? ;

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

: complete-editor? ( tokens -- ? ) "EDITOR:" complete-token? ;

<PRIVATE

: complete-string? ( tokens token -- ? )
    {
        [
            [ harvest ?last ] dip ?head
            [ ?last CHAR: \" = not ] [ drop f ] if
        ]
        [ complete-token? ]
    } 2|| ;

PRIVATE>

: complete-pathname? ( tokens -- ? ) "P\"" complete-string? ;

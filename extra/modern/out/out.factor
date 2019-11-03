! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
constructors continuations io io.encodings.utf8 io.files
io.streams.string kernel modern modern.compiler modern.paths
modern.slices prettyprint sequences sequences.extras splitting
strings syntax.modern vocabs.loader ;
IN: modern.out

TUPLE: renamed slice string ;
CONSTRUCTOR: <renamed> renamed ( slice string -- obj ) ;

: trim-before-newline ( seq -- seq' )
    dup [ char: \s = not ] find
    { char: \r char: \n } member?
    [ tail-slice ] [ drop ] if ;

: write-whitespace ( last obj -- )
    swap
    [ swap slice-between ] [ slice-before ] if*
    trim-before-newline >string io:write ;

GENERIC: write-literal* ( last obj -- last' )
M: slice write-literal* [ write-whitespace ] [ >string write ] [ ] tri ;
M: array write-literal* [ write-literal* ] each ;
M: lexed write-literal* tokens>> write-literal* ;
M: renamed write-literal*
    [ slice>> write-whitespace ]
    [ string>> write ]
    [ slice>> ] tri ; ! for refactoring
: write-literal ( obj -- ) f swap write-literal* drop ;

![[
DEFER: map-literals
: (map-literals) ( obj quot: ( obj -- obj' ) -- seq )
    over array? [
    ! over [ array? ] any? [
        [ call ] [ map-literals ] bi
    ] [
        over array? [ map-literals ] [ call ] if
    ] if ; inline recursive

: map-literals ( obj quot: ( obj -- obj' ) -- seq )
    '[ _ (map-literals) ] map ; inline recursive
]]

DEFER: map-literals
: map-literal ( obj quot: ( ..a obj -- ..a obj' ) -- obj )
    over section? [
        [ second ] dip map-literals concat
    ] [
        call
    ] if ; inline recursive

: map-literals ( seq quot: ( ..a obj -- ..a obj' ) -- seq' )
    '[ _ map-literal ] map ; inline recursive

![[
! ": foo ; <PRIV : bar ; PRIV>" string>literals [ B upper-colon? ] filter-literals >strings

DEFER: filter-literals
: filter-literal ( obj quot: ( ..a obj -- ..a obj' ) -- obj )
    over section? [
        B [ second ] dip filter-literals
    ] [
        call
    ] if ; inline recursive

: filter-literals ( seq quot: ( ..a obj -- ..a obj' ) -- seq' )
    { } pick length over [ (selector-as) [ each ] dip ] 2curry
    [ dip like ] 3curry
    '[ _ filter-literal ] filter ; inline recursive
]]

DEFER: map-literals!
: map-literal! ( obj quot: ( obj -- obj' ) -- obj )
    over { [ array? ] [ ?first section-open? ] } 1&& [
        [ call drop ] [
            map-literals!
        ] 2bi
    ] [
        call
    ] if ; inline recursive

: map-literals! ( seq quot: ( obj -- obj' ) -- seq )
    '[ _ map-literal! ] map! ; inline recursive


: write-modern-string ( seq -- string )
    [ write-literal ] with-string-writer ; inline

: write-modern-path ( seq path -- )
    utf8 [ write-literal "\n" write ] with-file-writer ; inline

: write-modern-vocab ( seq vocab -- )
    vocab-source-path write-modern-path ; inline

: rewrite-path ( path quot: ( obj -- obj' ) -- )
    ! dup print
    '[ [ path>literals _ map-literals ] [ ] bi write-modern-path ]
    [ drop . ] recover ; inline recursive

: rewrite-string ( string quot: ( obj -- obj' ) -- )
    ! dup print
    [ string>literals ] dip map-literals write-modern-string ; inline recursive

: rewrite-paths ( seq quot: ( obj -- obj' ) -- ) '[ _ rewrite-path ] each ; inline recursive

: rewrite-vocab ( vocab quot: ( obj -- obj' ) -- )
    [ [ vocab>literals ] dip map-literals ] 2keep drop write-modern-vocab ; inline recursive

: rewrite-string-exact ( string -- string' )
    string>literals write-modern-string ;

: strings-core-to-file ( -- )
    core-vocabs
    [ ".private" ?tail drop vocab-source-path utf8 file-contents ] map-zip
    [ "[========[" dup matching-delimiter-string surround ] assoc-map
    [
        first2 [ "VOCAB: " prepend ] dip " " glue
    ] map
    [ "    " prepend ] map "\n\n" join
    "<VOCAB-ROOT: factorcode-core \"https://factorcode.org/git/factor.git\" \"core/\"\n"
    "\n;VOCAB-ROOT>" surround "resource:core-strings.factor" utf8 set-file-contents ;

: parsed-core-to-file ( -- )
    core-vocabs
    [ vocab>literals ] map-zip
    [
        first2 [ "<VOCAB: " prepend ] dip
        >strings
        ! [ 3 head ] [ 3 tail* ] bi [ >strings ] bi@ { "..." } glue
        ";VOCAB>" 3array
    ] map 1array

    { "<VOCAB-ROOT:" "factorcode-core" "https://factorcode.org/git/factor.git" "core/" }
    { ";VOCAB-ROOT>" } surround "resource:core-parsed.factor" utf8 [ ... ] with-file-writer ;

![[
: rewrite-core-paths-with-semis ( -- )
    core-source-paths first [
        dup { [ array? ] [ ?first upper-colon? ] } 1&& [
            dup ?first >strings .
            dup length 2 = [
                first2 1 cut* { " " ";" } swap 3append 2array
            ] when
        ] when
    ] rewrite-path ;
]]

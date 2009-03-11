! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math sequences strings sets
assocs prettyprint.backend prettyprint.custom make lexer
namespaces parser arrays fry locals regexp.parser splitting
sorting regexp.ast regexp.negation regexp.compiler words
call call.private math.ranges ;
IN: regexp

TUPLE: regexp
    { raw read-only }
    { parse-tree read-only }
    { options read-only }
    dfa next-match ;

TUPLE: reverse-regexp < regexp ;

<PRIVATE

: maybe-negated ( lookaround quot -- regexp-quot )
    '[ term>> @ ] [ positive?>> [ ] [ not ] ? ] bi compose ; inline

M: lookahead question>quot ! Returns ( index string -- ? )
    [ ast>dfa dfa>shortest-word '[ f _ execute ] ] maybe-negated ;

: <reversed-option> ( ast -- reversed )
    "r" string>options <with-options> ;

M: lookbehind question>quot ! Returns ( index string -- ? )
    [
        <reversed-option>
        ast>dfa dfa>reverse-shortest-word
        '[ [ 1- ] dip f _ execute ]
    ] maybe-negated ;

: check-string ( string -- string )
    ! Make this configurable
    dup string? [ "String required" throw ] unless ;

: match-index-from ( i string regexp -- index/f )
    ! This word is unsafe. It assumes that i is a fixnum
    ! and that string is a string.
    dup dfa>> execute-unsafe( index string regexp -- i/f ) ;

GENERIC: end/start ( string regexp -- end start )
M: regexp end/start drop length 0 ;
M: reverse-regexp end/start drop length 1- -1 swap ;

PRIVATE>

: matches? ( string regexp -- ? )
    [ end/start ] 2keep
    [ check-string ] dip
    match-index-from
    [ swap = ] [ drop f ] if* ;

<PRIVATE

TUPLE: match { i read-only } { j read-only } { seq read-only } ;

: match-slice ( i string quot -- match/f )
    [ 2dup ] dip call
    [ swap match boa ] [ 2drop f ] if* ; inline

: search-range ( i string reverse? -- seq )
    [ drop 0 [a,b] ] [ length [a,b) ] if ; inline

: match>result ( match reverse? -- i start end string )
    over [
        [ [ i>> ] [ j>> tuck ] [ seq>> ] tri ] dip
        [ [ swap [ 1+ ] bi@ ] dip ] when
    ] [ 2drop f f f f ] if ; inline

:: next-match ( i string quot reverse? -- i start end string )
    i string reverse? search-range
    [ string quot match-slice ] map-find drop
    reverse? match>result ; inline

: do-next-match ( i string regexp -- i start end string )
    dup next-match>>
    execute-unsafe( i string regexp -- i start end string ) ;

: next-slice ( i string regexp -- i/f slice/f )
    do-next-match
    [ slice boa ] [ drop ] if* ; inline

PRIVATE>

TUPLE: match-iterator
    { string read-only }
    { regexp read-only }
    { i read-only }
    { value read-only } ;

: iterate ( iterator -- iterator'/f )
    dup
    [ i>> ] [ string>> ] [ regexp>> ] tri next-slice
    [ [ [ string>> ] [ regexp>> ] bi ] 2dip match-iterator boa ]
    [ 2drop f ] if* ;

: value ( iterator/f -- value/f )
    dup [ value>> ] when ;

: <match-iterator> ( string regexp -- match-iterator )
    [ check-string ] dip
    2dup end/start nip f
    match-iterator boa
    iterate ; inline

: all-matches ( string regexp -- seq )
    <match-iterator> [ iterate ] follow [ value ] map ;

: count-matches ( string regexp -- n )
    all-matches length ;

<PRIVATE

:: split-slices ( string slices -- new-slices )
    slices [ to>> ] map 0 prefix
    slices [ from>> ] map string length suffix
    [ string <slice> ] 2map ;

PRIVATE>

: first-match ( string regexp -- slice/f )
    <match-iterator> value ;

: re-contains? ( string regexp -- ? )
    first-match >boolean ;

: re-split1 ( string regexp -- before after/f )
    dupd first-match [ 1array split-slices first2 ] [ f ] if* ;

: re-split ( string regexp -- seq )
    dupd all-matches split-slices ;

: re-replace ( string regexp replacement -- result )
    [ re-split ] dip join ;

<PRIVATE

: get-ast ( regexp -- ast )
    [ parse-tree>> ] [ options>> ] bi <with-options> ;

GENERIC: compile-regexp ( regex -- regexp )

: regexp-initial-word ( i string regexp -- i/f )
    compile-regexp match-index-from ;

: do-compile-regexp ( regexp -- regexp )
    dup '[
        dup \ regexp-initial-word =
        [ drop _ get-ast ast>dfa dfa>word ] when
    ] change-dfa ;

M: regexp compile-regexp ( regexp -- regexp )
    do-compile-regexp ;

M: reverse-regexp compile-regexp ( regexp -- regexp )
    t backwards? [ do-compile-regexp ] with-variable ;

DEFER: compile-next-match

: next-initial-word ( i string regexp -- i start end string )
    compile-next-match do-next-match ;

: compile-next-match ( regexp -- regexp )
    dup '[
        dup \ next-initial-word = [
            drop _ [ compile-regexp dfa>> ] [ reverse-regexp? ] bi
            '[ _ '[ _ _ execute ] _ next-match ]
            (( i string regexp -- i start end string )) simple-define-temp
        ] when
    ] change-next-match ;

PRIVATE>

: new-regexp ( string ast options class -- regexp )
    [ \ regexp-initial-word \ next-initial-word ] dip boa ; inline

: make-regexp ( string ast -- regexp )
    f f <options> regexp new-regexp ;

: <optioned-regexp> ( string options -- regexp )
    [ dup parse-regexp ] [ string>options ] bi*
    dup on>> reversed-regexp swap member?
    [ reverse-regexp new-regexp ]
    [ regexp new-regexp ] if ;

: <regexp> ( string -- regexp ) "" <optioned-regexp> ;

<PRIVATE

! The following two should do some caching

: find-regexp-syntax ( string -- prefix suffix )
    {
        { "R/ "  "/"  }
        { "R! "  "!"  }
        { "R\" " "\"" }
        { "R# "  "#"  }
        { "R' "  "'"  }
        { "R( "  ")"  }
        { "R@ "  "@"  }
        { "R[ "  "]"  }
        { "R` "  "`"  }
        { "R{ "  "}"  }
        { "R| "  "|"  }
    } swap [ subseq? not nip ] curry assoc-find drop ;

: take-until ( end lexer -- string )
    dup skip-blank [
        [ index-from ] 2keep
        [ swapd subseq ]
        [ 2drop 1+ ] 3bi
    ] change-lexer-column ;

: parse-noblank-token ( lexer -- str/f )
    dup still-parsing-line? [ (parse-token) ] [ drop f ] if ;

: parsing-regexp ( accum end -- accum )
    lexer get [ take-until ] [ parse-noblank-token ] bi
    <optioned-regexp> compile-next-match parsed ;

PRIVATE>

: R! CHAR: ! parsing-regexp ; parsing
: R" CHAR: " parsing-regexp ; parsing
: R# CHAR: # parsing-regexp ; parsing
: R' CHAR: ' parsing-regexp ; parsing
: R( CHAR: ) parsing-regexp ; parsing
: R/ CHAR: / parsing-regexp ; parsing
: R@ CHAR: @ parsing-regexp ; parsing
: R[ CHAR: ] parsing-regexp ; parsing
: R` CHAR: ` parsing-regexp ; parsing
: R{ CHAR: } parsing-regexp ; parsing
: R| CHAR: | parsing-regexp ; parsing

M: regexp pprint*
    [
        [
            [ raw>> dup find-regexp-syntax swap % swap % % ]
            [ options>> options>string % ] bi
        ] "" make
    ] keep present-text ;


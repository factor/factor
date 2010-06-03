! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel kernel.private math sequences
sequences.private strings sets assocs make lexer namespaces parser
arrays fry locals regexp.parser splitting sorting regexp.ast
regexp.negation regexp.compiler compiler.units words math.ranges ;
IN: regexp

TUPLE: regexp
    { raw read-only }
    { parse-tree read-only }
    { options read-only }
    dfa next-match ;

TUPLE: reverse-regexp < regexp ;

<PRIVATE

M: lookahead question>quot ! Returns ( index string -- ? )
    term>> ast>dfa dfa>shortest-word '[ f _ execute ] ;

: <reversed-option> ( ast -- reversed )
    "r" string>options <with-options> ;

M: lookbehind question>quot ! Returns ( index string -- ? )
    term>> <reversed-option>
    ast>dfa dfa>reverse-shortest-word
    '[ [ 1 - ] dip f _ execute ] ;

: check-string ( string -- string )
    ! Make this configurable
    dup string? [ "String required" throw ] unless ;

: match-index-from ( i string regexp -- index/f )
    ! This word is unsafe. It assumes that i is a fixnum
    ! and that string is a string.
    dup dfa>> execute( index string regexp -- i/f ) ; inline

GENERIC: end/start ( string regexp -- end start )
M: regexp end/start drop length 0 ;
M: reverse-regexp end/start drop length 1 - -1 swap ;

PRIVATE>

: matches? ( string regexp -- ? )
    [ check-string ] dip
    [ end/start ] 2keep
    match-index-from
    [ = ] [ drop f ] if* ;

<PRIVATE

:: (next-match) ( i string regexp quot: ( i string regexp -- j ) reverse? -- i start end ? )
    i string regexp quot call dup [| j |
        j i j
        reverse? [ swap [ 1 + ] bi@ ] when
        string
    ] [ drop f f f f ] if ; inline

: search-range ( i string reverse? -- seq )
    [ drop dup 1 + -1 ] [ length 1 ] if range boa ; inline

:: next-match ( i string regexp quot: ( i string regexp -- j ) reverse? -- i start end ? )
    f f f f
    i string reverse? search-range
    [ [ 2drop 2drop ] dip string regexp quot reverse? (next-match) dup ] find 2drop ; inline

: do-next-match ( i string regexp -- i start end ? )
    dup next-match>>
    execute( i string regexp -- i start end ? ) ; inline

:: (each-match) ( ... i string regexp quot: ( ... start end string -- ... ) -- ... )
    i string regexp do-next-match [| i' start end |
        start end string quot call
        i' string regexp quot (each-match)
    ] [ 3drop ] if ; inline recursive

: prepare-match-iterator ( string regexp -- i string regexp )
    [ check-string ] dip [ end/start nip ] 2keep ; inline

PRIVATE>

: each-match ( ... string regexp quot: ( ... start end string -- ... ) -- ... )
    [ prepare-match-iterator ] dip (each-match) ; inline

: map-matches ( ... string regexp quot: ( ... start end string -- ... obj ) -- ... seq )
    collector [ each-match ] dip >array ; inline

: all-matching-slices ( string regexp -- seq )
    [ slice boa ] map-matches ;

: all-matching-subseqs ( string regexp -- seq )
    [ subseq ] map-matches ;

: count-matches ( string regexp -- n )
    [ 0 ] 2dip [ 3drop 1 + ] each-match ;

<PRIVATE

:: (re-split) ( string regexp quot -- new-slices )
    0 string regexp [| end start end' string |
        end' ! leave it on the stack for the next iteration
        end start string quot call
    ] map-matches
    ! Final chunk
    swap string length string quot call suffix ; inline

PRIVATE>

: first-match ( string regexp -- slice/f )
    [ prepare-match-iterator do-next-match ] [ drop ] 2bi
    '[ _ slice boa nip ] [ 3drop f ] if ;

: re-contains? ( string regexp -- ? )
    prepare-match-iterator do-next-match [ 3drop ] dip >boolean ;

: re-split ( string regexp -- seq )
    [ slice boa ] (re-split) ;

: re-replace ( string regexp replacement -- result )
    [ [ subseq ] (re-split) ] dip join ;

<PRIVATE

: get-ast ( regexp -- ast )
    [ parse-tree>> ] [ options>> ] bi <with-options> ;

GENERIC: compile-regexp ( regex -- regexp )

: regexp-initial-word ( i string regexp -- i/f )
    [ compile-regexp ] with-compilation-unit match-index-from ;

M: regexp compile-regexp ( regexp -- regexp )
    dup '[
        dup \ regexp-initial-word =
        [ drop _ get-ast ast>dfa dfa>word ] when
    ] change-dfa ;

M: reverse-regexp compile-regexp ( regexp -- regexp )
    t backwards? [ call-next-method ] with-variable ;

DEFER: compile-next-match

: next-initial-word ( i string regexp -- i start end string )
    [ compile-next-match ] with-compilation-unit do-next-match ;

: compile-next-match ( regexp -- regexp )
    dup '[
        dup \ next-initial-word = [
            drop _ [ compile-regexp dfa>> def>> ] [ reverse-regexp? ] bi
            '[ { array-capacity string regexp } declare _ _ next-match ]
            (( i string regexp -- i start end string )) define-temp
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
        [ 2drop 1 + ] 3bi
    ] change-lexer-column ;

: parse-noblank-token ( lexer -- str/f )
    dup still-parsing-line? [ (parse-token) ] [ drop f ] if ;

: parsing-regexp ( accum end -- accum )
    lexer get [ take-until ] [ parse-noblank-token ] bi
    <optioned-regexp> compile-next-match suffix! ;

PRIVATE>

SYNTAX: R! CHAR: ! parsing-regexp ;
SYNTAX: R" CHAR: " parsing-regexp ;
SYNTAX: R# CHAR: # parsing-regexp ;
SYNTAX: R' CHAR: ' parsing-regexp ;
SYNTAX: R( CHAR: ) parsing-regexp ;
SYNTAX: R/ CHAR: / parsing-regexp ;
SYNTAX: R@ CHAR: @ parsing-regexp ;
SYNTAX: R[ CHAR: ] parsing-regexp ;
SYNTAX: R` CHAR: ` parsing-regexp ;
SYNTAX: R{ CHAR: } parsing-regexp ;
SYNTAX: R| CHAR: | parsing-regexp ;

USE: vocabs.loader

{ "prettyprint" "regexp" } "regexp.prettyprint" require-when

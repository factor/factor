! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes compiler.units kernel
kernel.private lexer make math ranges namespaces quotations
regexp.ast regexp.compiler regexp.negation regexp.parser
sequences sequences.private splitting strings vocabs.loader
words ;
IN: regexp

TUPLE: regexp
    { raw read-only }
    { parse-tree read-only }
    { options read-only }
    dfa next-match ;

TUPLE: reverse-regexp < regexp ;

<PRIVATE

M: lookahead question>quot
    ! Returns ( index string -- ? )
    term>> ast>dfa dfa>shortest-word 1quotation [ f ] prepose ;

: <reversed-option> ( ast -- reversed )
    "r" string>options <with-options> ;

M: lookbehind question>quot
    ! Returns ( index string -- ? )
    term>> <reversed-option>
    ast>dfa dfa>reverse-shortest-word
    1quotation [ [ 1 - ] dip f ] prepose ;

: match-index-from ( i string regexp -- index/f )
    ! This word is unsafe. It assumes that i is a fixnum
    ! and that string is a string.
    dup dfa>> execute( index string regexp -- i/f ) ; inline

GENERIC: end/start ( string regexp -- end start )
M: regexp end/start drop length 0 ;
M: reverse-regexp end/start drop length 1 - -1 swap ;

PRIVATE>

: matches? ( string regexp -- ? )
    [ string check-instance ] dip
    [ end/start ] 2keep
    match-index-from
    [ = ] [ drop f ] if* ;

<PRIVATE

: search-range ( i string reverse? -- seq )
    [ drop -1 ] [ length ] if [a..b] ; inline

:: (next-match) ( i string regexp quot: ( i string regexp -- j ) reverse? -- start end ? )
    i string regexp quot call dup
    [| j | reverse? [ j i ] [ i j ] if string ] [ drop f f f ] if ; inline

:: next-match ( i string regexp quot: ( i string regexp -- j ) reverse? -- start end ? )
    f f f
    i string reverse? search-range
    [ 3nip string regexp quot reverse? (next-match) dup ] find 2drop ; inline

: do-next-match ( i string regexp -- start end ? )
    dup next-match>>
    execute( i string regexp -- start end ? ) ; inline

:: (each-match-forward) ( ... i string regexp quot: ( ... start end string -- ... ) -- ... )
    i string length <= [
        i string regexp do-next-match [| start end |
            start end string quot call
            start end eq? [ end 1 +  ] [ end ] if
            string regexp quot (each-match-forward)
        ] [ 2drop ] if
    ] when ; inline recursive

:: (each-match-backward) ( ... i string regexp quot: ( ... start end string -- ... ) -- ... )
    i -1 >= [
        i string regexp do-next-match [| start end |
            start 1 + end 1 + string quot call
            start end eq? [ start 1 - ] [ start ] if
            string regexp quot (each-match-backward)
        ] [ 2drop ] if
    ] when ; inline recursive

: (each-match) ( ... i string regexp quot: ( ... start end string -- ... ) -- ... )
    over reverse-regexp? [ (each-match-backward) ] [ (each-match-forward) ] if ; inline

GENERIC: match-iterator-start ( string regexp -- start )
M: regexp match-iterator-start 2drop 0 ;
M: reverse-regexp match-iterator-start drop length ;

: prepare-match-iterator ( string regexp -- i string regexp )
    [ string check-instance ] dip [ match-iterator-start ] 2keep ; inline

PRIVATE>

: each-match ( ... string regexp quot: ( ... start end string -- ... ) -- ... )
    [ prepare-match-iterator ] dip (each-match) ; inline

: map-matches ( ... string regexp quot: ( ... start end string -- ... obj ) -- ... seq )
    collector [ each-match ] dip >array ; inline

: all-matching-slices ( string regexp -- seq )
    [ <slice-unsafe> ] map-matches ;

: all-matching-subseqs ( string regexp -- seq )
    [ subseq ] map-matches ;

: count-matches ( string regexp -- n )
    [ 0 ] 2dip [ 3drop 1 + ] each-match ;

<PRIVATE

:: (re-split) ( string regexp quot: ( from to seq -- slice ) -- new-slices )
    0 string regexp [| end start end' string |
        end' ! leave it on the stack for the next iteration
        end start string quot call
    ] map-matches
    ! Final chunk
    swap string length string quot call suffix ; inline

PRIVATE>

:: first-match ( string regexp -- slice/f )
    string regexp prepare-match-iterator do-next-match [
        regexp reverse-regexp? [ [ 1 + ] bi@ ] when
        string <slice-unsafe>
    ] [ 2drop f ] if ;

: re-contains? ( string regexp -- ? )
    prepare-match-iterator do-next-match 2nip >boolean ;

: re-split ( string regexp -- seq )
    [ <slice-unsafe> ] (re-split) ;

: re-replace ( string regexp replacement -- result )
    [ [ subseq ] (re-split) ] dip join ;

:: re-replace-with ( string regexp quot: ( slice -- replacement ) -- result )
    [
        0 string regexp [
            drop [ [ string <slice-unsafe> , ] keep ] dip
            [ string <slice-unsafe> quot call( x -- x ) , ] keep
        ] each-match string [ length ] [ <slice-unsafe> ] bi ,
    ] { } make concat ;

<PRIVATE

: get-ast ( regexp -- ast )
    [ parse-tree>> ] [ options>> ] bi <with-options> ;

GENERIC: compile-regexp ( regex -- regexp )

: regexp-initial-word ( i string regexp -- i/f )
    [ compile-regexp ] with-compilation-unit match-index-from ;

M: regexp compile-regexp
    dup '[
        dup \ regexp-initial-word =
        [ drop _ get-ast ast>dfa dfa>word ] when
    ] change-dfa ;

M: reverse-regexp compile-regexp
    t backwards? [ call-next-method ] with-variable ;

DEFER: compile-next-match

: next-initial-word ( i string regexp -- start end string )
    [ compile-next-match ] with-compilation-unit do-next-match ;

: compile-next-match ( regexp -- regexp )
    dup '[
        dup \ next-initial-word = [
            drop _ [ compile-regexp dfa>> def>> ] [ reverse-regexp? ] bi
            '[ { array-capacity string regexp } declare _ _ next-match ]
            ( i string regexp -- start end string ) define-temp
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

: take-until ( lexer -- string )
    dup skip-blank [
        dupd [
            [ [ "\\/" member? ] find-from ] keep swap [
                CHAR: \ = [ [ 2 + ] dip t ] [ f ] if
            ] [
                "Unterminated regexp" throw
            ] if*
        ] loop over [ subseq ] dip 1 +
    ] change-lexer-column ;

: parse-noblank-token ( lexer -- str/f )
    dup still-parsing-line? [ (parse-raw) ] [ drop f ] if ;

: parse-regexp ( accum -- accum )
    lexer get [ take-until "\\/" "/" replace ] [ parse-noblank-token ] bi
    <optioned-regexp> compile-next-match suffix! ;

PRIVATE>

SYNTAX: R/ parse-regexp ;


{ "prettyprint" "regexp" } "regexp.prettyprint" require-when

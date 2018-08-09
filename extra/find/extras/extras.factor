! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators combinators.extras
combinators.smart fry generalizations kernel literals locals
macros make math math.private modern.slices multiline namespaces
quotations sequences sequences.deep sequences.extras
sequences.generalizations sequences.private shuffle
stack-checker.transforms strings unicode words ;
IN: find.extras

SYMBOL: delimiter-stack

: with-delimiter-stack ( string quot -- seq )
    [ V{ } clone delimiter-stack ] dip with-variable ; inline

: push-delimiter ( delim -- )
    delimiter-stack get push ;

: peek-delimiter ( -- delim/f )
    delimiter-stack get [ f ] [ last ] if-empty ;

ERROR: delimiter-mismatch-error got expected ;
: pop-delimiter ( delim -- )
    delimiter-stack get pop
    2dup matching-delimiter-string 2dup sequence= [ 4drop ] [ delimiter-mismatch-error ] if ;

ERROR: unmatched-delimiter delimiter delimiter-string ;
: check-delimiter-stack ( -- )
    delimiter-stack get [
        first dup >string unmatched-delimiter
    ] unless-empty ;

ERROR: invalid-slice seq from to ;
: range-empty-slice ( seq from to -- seq n' slice )
    2dup > [ invalid-slice ] when
    [ 2drop ]
    [ [ rot <slice> ] keep swap ] 3bi ; inline

: range-slice ( seq from to -- seq n' slice )
    2dup = [ drop f ] [ range-empty-slice ] if ; inline

: length-slice ( seq from len -- seq n' slice )
    [ 2drop ]
    [ [ drop ] [ + ] 2bi [ rot <slice> ] keep swap ] 3bi ; inline

: head-from? ( seq n subseq -- ? )
    over [ [ short tail-slice ] dip head? ] [ 3drop f ] if ; inline

: head-from ( seq n subseq -- seq n/f subseq/f )
    3dup head-from? [ length length-slice ] [ drop f ] if ;

: before-from? ( seq n subseq -- ? )
    [ length - ] keep over 0 < [ 3drop f ] [ head-from? ] if ;

: guard-length ( seq n -- seq n/f ? )
    dup [ 2dup [ length ] dip > ] [ f ] if ; inline

: take-loop ( seq n quot: ( seq n slice -- seq n' slice/f ) -- seq n'/f )
    [ guard-length ] dip swap [
        [ swapd [ nth ] dip call ] 3keep roll
        [ [ 1 + ] dip take-loop ] [ drop ] if
    ] [
        drop
    ] if ; inline recursive

: take-empty-from ( seq n quot -- seq n'/f subseq/f )
    [ take-loop ] 3keep drop
    nip swap [ range-empty-slice ] [ drop f f ] if* ; inline

: take-from ( seq n quot -- seq n'/f subseq/f )
    [ take-loop ] 3keep drop
    nip swap [ range-slice ] [ drop f f ] if* ; inline

: find-until-subseq ( seq n subseq -- seq n'/f subseq/f )
    3dup -rot subseq-start-from [
        nip
        [ pick <slice> ] keep swap
    ] [
        2drop f f
    ] if* ;

: find-subseq-from ( seq n subseq -- seq n'/f subseq/f )
    over [
        3dup -rot subseq-start-from [
            swap length +
            [ pick <slice> ] keep swap
        ] [
            2drop f f
        ] if*
    ] [
        2drop f f
    ] if ;

<<
:: quots>find-quot ( quots -- quot )
    quots length :> n
    n 1 - :> nless
    quots [ ] like
    n [ [ call ] nless ndip n nrot ] n*quot
    '[ [ @ @ n narray ] keep
    over [ ] all? [ drop ] [ -rot 2drop f ] if ] ;
>>
MACRO: find-quots ( quots -- quot ) quots>find-quot ;

: slices-combine ( seq -- slice )
    [ f ]
    [ [ first from>> ] [ last to>> ] [ last seq>> ] tri <slice> ] if-empty ;

: slices-length ( seq -- n )
    [ 0 ] [ [ last to>> ] [ first from>> ] bi - ] if-empty ;

: inc-length ( seq n -- seq n'/f )
    2dup [ length ] dip > [ 1 + ] [ drop f ] if ; inline

: find-until-quots-step ( seq n quot -- seq n'/f )
    over [
        [ call ] keep swap [
            slices-length nip -
        ] [
            [ inc-length ] dip find-until-quots-step
        ] if*
    ] [
        2drop f
    ] if ; inline

MACRO: find-until-quots ( quots -- quot ) ! : ( seq n -- seq n'/f slice/f ) )
    quots>find-quot
    '[
        _ [ find-until-quots-step ] 3keep drop nip swap [
            [ pick <slice> ] keep swap
        ] [
            drop f f
        ] if*
    ] ;
<<
CONSTANT: whitespace-separators "\s\t\r\n"
CONSTANT: modern-separators "[]{}()<>:;,`\\!\"'"
>>
CONSTANT: all-separators $[ whitespace-separators modern-separators append ]

: tag-from ( seq n -- seq n' slice )
    [ all-separators member? not ] take-empty-from ;

: read-until-subseq ( seq n delimiter -- seq' n' payload delimiter )
    [ find-until-subseq ] keep
    '[ _ head-from ] dip swap ;

: opening-lua-bracket-from ( seq n -- seq n' slices )
    { [ tag-from ] [ "[" head-from ] [ [ ch'= = ] take-empty-from ] [ "[" head-from ] }
    find-quots ;

: opening-lua-brace-from ( seq n -- seq n' slices )
    { [ tag-from ] [ "{" head-from ] [ [ ch'= = ] take-empty-from ] [ "{" head-from ] }
    find-quots ;

: opening-lua-paren-from ( seq n -- seq n' slices )
    { [ tag-from ] [ "(" head-from ] [ [ ch'= = ] take-empty-from ] [ "(" head-from ] }
    find-quots ;

: read-lua-string ( seq n pair -- seq n' )
    [ first , ] [ rest ] bi slices-combine dup ,
    matching-delimiter-string
    read-until-subseq [ , ] bi@ ;

: skip-whitespace ( seq n -- seq n'/f )
    [ whitespace-separators member? ] take-empty-from drop ;

: tagged-bracket-open-from ( seq n -- seq n' slice ) { [ tag-from ] [ "[" head-from ] } find-quots ;
: tagged-brace-open-from ( seq n -- seq n' slice ) { [ tag-from ] [ "{" head-from ] } find-quots ;
: tagged-paren-open-from ( seq n -- seq n' slice ) { [ tag-from ] [ "(" head-from ] } find-quots ;
: tagged-colon-open-from ( seq n -- seq n' slice ) { [ tag-from ] [ ":" head-from ] } find-quots ;
: tagged-sstring-open-from ( seq n -- seq n' slice ) { [ tag-from ] [ "'" head-from ] } find-quots ;
: tagged-dstring-open-from ( seq n -- seq n' slice ) { [ tag-from ] [ "\"" head-from ] } find-quots ;
: tagged-backtick-open-from ( seq n -- seq n' slice ) { [ tag-from ] [ "`" head-from ] } find-quots ;
: html-open-from ( seq n -- seq n' slice ) { [ "<" head-from ] [ tag-from ] [ ">" head-from ] } find-quots ;
: html-close-from ( seq n -- seq n' slice ) { [ "</" head-from ] [ tag-from ] [ ">" head-from ] } find-quots ;
: html-self-close-from ( seq n -- seq n' slice ) { [ "<" head-from ] [ tag-from ] [ "/>" head-from ] } find-quots ;
: matching-closing-tag ( slice -- string' ) rest "</" prepend ;

DEFER: lex-token
: lex-tagged-brace ( seq n -- seq n' slice )
    { [ tagged-brace-open-from ] [ lex-token ] [ "}" head-from ] } find-quots ;

: lex-until ( seq n string -- seq n'/f seq' )
    '[
        [
            lex-token [
                dup [ slice? ] all?
                [ slices-combine dup , _ sequence= not ] [ , t ] if
            ] [ f ] if*
        ] loop
    ] { } make ; inline

ERROR: unmatched-syntax seq n obj delimiter ;

: read-syntax ( seq n slices delimiter -- seq n' obj )
    [ slices-combine ] dip
    dup dup dup '[
        _ lex-until dup empty? [ _ unmatched-syntax ] when
       dup last _ sequence= [ _ unmatched-syntax ] unless unclip-last
    ] dip -rot 3array ;


:: (read-matching-char-with-escape) ( seq n escape delimiter -- seq' n' )
    seq n guard-length [
        delimiter find-subseq-from [
            drop 2dup escape delimiter append before-from? [
                escape delimiter (read-matching-char-with-escape)
            ] when
        ] when*
    ] [
        drop f
    ] if ;

:: read-matching-char-with-escape ( seq n escape-string close-delimiter -- seq' n'/f payload close-delimiter )
    seq n escape-string close-delimiter (read-matching-char-with-escape) :> ( seq n' )
    n' [
        seq n'
        n n' 1 - seq <slice>
        n' 1 - n' seq <slice>
    ] [
        seq f
        seq close-delimiter tail? [ "bad" throw ] unless
        n  seq length  close-delimiter length -  seq <slice>
        seq length [ close-delimiter length - ] keep seq <slice>
    ] if ;

:: handle-closing-delimiter ( delim -- delim opening? )
    peek-delimiter :> peeked
    delim peeked sequence= [
        ! } }
        delimiter-stack get pop*
        delim f
    ] [
        delim peeked matching-delimiter-string sequence= [
            ! { }
            delimiter-stack get pop*
            delim f
        ] [
            delim delimiter-stack get push
            delim t
        ] if
    ] if ;

: handle-open-close-delimiter ( seq n delim -- seq n' )
    handle-closing-delimiter
    [ dup , lex-until unclip-last [ , ] bi@ ] [ , ] if ;

: lex-token ( seq n -- seq n seq' )
    [
        skip-whitespace guard-length [
            {
                ! Closing delimiters needed to avoid 0-width tag-from slices
                { [ ";" head-from ] [ , ] }
                { [ ">" head-from ] [ , ] }
                { [ "," head-from ] [ , ] }
                { [ "#" head-from ] [ , [ "\r\n" member? not ] take-empty-from , ] }

                { [ "))" head-from ] [ , ] }
                { [ "}}" head-from ] [ , ] }
                { [ "]]" head-from ] [ , ] }
                { [ ")" head-from ] [ handle-open-close-delimiter ] }
                { [ "}" head-from ] [ handle-open-close-delimiter ] }
                { [ "]" head-from ] [ handle-open-close-delimiter ] }
                { [ opening-lua-bracket-from ] [ read-lua-string ] }
                { [ opening-lua-brace-from ] [ read-lua-string ] }
                { [ opening-lua-paren-from ] [ read-lua-string ] }
                
                { [ tagged-bracket-open-from ] [ dup second push-delimiter "]" read-syntax % ] }
                { [ tagged-brace-open-from ] [ dup second push-delimiter "}" read-syntax % ] }
                { [ tagged-paren-open-from ] [ dup second push-delimiter ")" read-syntax % ] }
                { [ tagged-colon-open-from ] [ ";" read-syntax % ] }
                ! { [ tagged-sstring-open-from ] [ % "\\" "'" read-matching-char-with-escape [ , ] bi@ ] }
                { [ tagged-dstring-open-from ] [ % "\\" "\"" read-matching-char-with-escape [ , ] bi@ ] }
                { [ html-open-from ] [ dup slices-combine matching-closing-tag read-syntax % ] }
                { [ html-close-from ] [ % ] }
                { [ html-self-close-from ] [ % ] }

                ! Self-matching delimiter
                { [ tagged-backtick-open-from ] [ % "`" read-until-subseq [ , ] bi@ ] }
                [ [ "[]{}<>:;,`\\!\"' " member? not ] take-empty-from , ]
            } cond*
        ] when
    ] { } make f like ;

: lex-tokens ( string -- seq )
    '[
        _ 0 [ lex-token ] loop>array 2nip
        check-delimiter-stack
    ] with-delimiter-stack ;

: lex>strings ( seq -- strings ) [ 0 lex-token ] with-delimiter-stack >strings 2nip ;

: parse-prefix ( string n -- string n' obj )
    [ blank? ] take-empty-from drop
    {
        { [ "-" head-from ] [ ] }
        { [ "+" head-from ] [ ] }
        { [ "!" head-from ] [ ] }
        { [ "~" head-from ] [ ] }
        [ f ]
    } cond* ;

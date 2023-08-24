! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators continuations effects
kernel lexer make namespaces parser sequences sets
splitting vocabs.parser words ;
IN: effects.parser

DEFER: parse-effect

ERROR: bad-effect ;
ERROR: invalid-row-variable ;
ERROR: row-variable-can't-have-type ;
ERROR: stack-effect-omits-dashes ;

SYMBOL: effect-var

<PRIVATE
: end-token? ( end token -- token ? ) [ nip ] [ = ] 2bi ; inline
: effect-opener? ( token -- token ? ) dup { f "(" "--" } member? ; inline
: effect-closer? ( token -- token ? ) dup ")" sequence= ; inline
: row-variable? ( token -- token' ? ) ".." ?head ; inline
: standalone-type? ( token -- token' ? ) ":" ?head ; inline

: parse-effect-var ( first? var name -- var )
    nip
    [ ":" ?tail [ row-variable-can't-have-type ] when ] curry
    [ invalid-row-variable ] if ;

: parse-effect-value ( token -- value )
    ":" ?tail [ scan-object 2array ] when ;

ERROR: bad-standalone-effect obj ;
: parse-standalone-type ( obj -- var )
    parse-datum
    dup parsing-word? [
        V{ } clone swap execute-parsing dup length 1 =
        [ first ] [ bad-standalone-effect ] if
    ] when f swap 2array ;
PRIVATE>

: parse-effect-token ( first? var end -- var more? )
    scan-token {
        { [ end-token? ] [ drop nip f ] }
        { [ effect-opener? ] [ bad-effect ] }
        { [ effect-closer? ] [ stack-effect-omits-dashes ] }
        { [ row-variable? ] [ parse-effect-var t ] }
        [
            nipd standalone-type?
            [ parse-standalone-type ] [ parse-effect-value ] if , t
        ]
    } cond ;

: parse-effect-tokens ( end -- var tokens )
    '[ t f [ _ parse-effect-token [ f ] 2dip ] loop nip ] { } make ;

: parse-effect ( end -- effect )
    [ "--" parse-effect-tokens ] dip parse-effect-tokens
    <variable-effect> ;

: scan-effect ( -- effect )
    "(" expect ")" parse-effect ;

: parse-call-paren ( accum word -- accum )
    [ ")" parse-effect ] dip 2array append! ;

CONSTANT: in-definition HS{ }

ERROR: can't-nest-definitions word ;

: set-in-definition ( -- )
    manifest get current-vocab>> t or in-definition ?adjoin
    [ last-word can't-nest-definitions ] unless ;

: unset-in-definition ( -- )
    manifest get current-vocab>> t or in-definition delete ;

: with-definition ( quot -- )
    [ set-in-definition ] prepose [ unset-in-definition ] finally ; inline

: (:) ( -- word def effect )
    [
        scan-new-word
        scan-effect
        parse-definition swap
    ] with-definition ;

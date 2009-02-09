! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables io kernel math math.parser memory
namespaces parser lexer sequences strings io.styles
vectors words generic system combinators continuations debugger
definitions compiler.units accessors colors prettyprint fry
sets vocabs.parser call ;
IN: listener

GENERIC: stream-read-quot ( stream -- quot/f )

: parse-lines-interactive ( lines -- quot/f )
    [ parse-lines in get ] with-compilation-unit in set ;

: read-quot-step ( lines -- quot/f )
    [ parse-lines-interactive ] [
        dup error>> unexpected-eof?
        [ 2drop f ] [ rethrow ] if
    ] recover ;

: read-quot-loop ( stream accum -- quot/f )
    over stream-readln dup [
        over push
        dup read-quot-step dup
        [ 2nip ] [ drop read-quot-loop ] if
    ] [
        3drop f
    ] if ;

M: object stream-read-quot
    V{ } clone read-quot-loop ;

: read-quot ( -- quot/f ) input-stream get stream-read-quot ;

<PRIVATE

SYMBOL: quit-flag

PRIVATE>

: bye ( -- ) quit-flag on ;

SYMBOL: visible-vars

: show-var ( var -- ) visible-vars  [ swap suffix ] change ;

: show-vars ( seq -- ) visible-vars [ swap union ] change ;

: hide-var ( var -- ) visible-vars [ remove ] change ;

: hide-vars ( seq -- ) visible-vars [ swap diff ] change ;

: hide-all-vars ( -- ) visible-vars off ;

SYMBOL: error-hook

: call-error-hook ( error -- )
    error-continuation get error-hook get
    call( error continuation -- ) ;

[ drop print-error-and-restarts ] error-hook set-global

SYMBOL: display-stacks?

t display-stacks? set-global

SYMBOL: max-stack-items

10 max-stack-items set-global

<PRIVATE

: title. ( string -- )
    H{ { foreground T{ rgba f 0.3 0.3 0.3 1 } } } format nl ;

: visible-vars. ( -- )
    visible-vars get [
        nl "--- Watched variables:" title.
        standard-table-style [
            [
                [
                    [ [ short. ] with-cell ]
                    [ [ get short. ] with-cell ]
                    bi
                ] with-row
            ] each
        ] tabular-output
    ] unless-empty ;
    
: trimmed-stack. ( seq -- )
    dup length max-stack-items get > [
        max-stack-items get cut*
        [
            [ length number>string "(" " more items)" surround ] keep
            write-object nl
        ] dip
    ] when stack. ;

: stacks. ( -- )
    display-stacks? get [
        datastack [ nl "--- Data stack:" title. trimmed-stack. ] unless-empty
    ] when ;

: prompt. ( -- )
    "( " in get auto-use? get [ " - auto" append ] when " )" 3append
    H{ { background T{ rgba f 1 0.7 0.7 1 } } } format bl flush ;

: listen ( -- )
    visible-vars. stacks. prompt.
    [ read-quot [ [ call-error-hook ] recover ] [ bye ] if* ]
    [ dup lexer-error? [ call-error-hook ] [ rethrow ] if ] recover ;

: until-quit ( -- )
    quit-flag get [ quit-flag off ] [ listen until-quit ] if ;

PRIVATE>

: listener ( -- )
    [ until-quit ] with-interactive-vocabs ;

MAIN: listener

! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables io kernel math math.parser memory
namespaces parser sequences strings io.styles
io.streams.duplex vectors words generic system combinators
continuations debugger definitions compiler.units accessors ;
IN: listener

SYMBOL: quit-flag

SYMBOL: listener-hook

[ ] listener-hook set-global

GENERIC: stream-read-quot ( stream -- quot/f )

: parse-lines-interactive ( lines -- quot/f )
    [ parse-lines in get ] with-compilation-unit in set ;

: read-quot-step ( lines -- quot/f )
    [ parse-lines-interactive ] [
        dup error>> unexpected-eof?
        [ 2drop f ] [ rethrow ] if
    ] recover ;

: read-quot-loop  ( stream accum -- quot/f )
    over stream-readln dup [
        over push
        dup read-quot-step dup
        [ 2nip ] [ drop read-quot-loop ] if
    ] [
        3drop f
    ] if ;

M: object stream-read-quot
    V{ } clone read-quot-loop ;

M: duplex-stream stream-read-quot
    duplex-stream-in stream-read-quot ;

: read-quot ( -- quot/f ) stdio get stream-read-quot ;

: bye ( -- ) quit-flag on ;

: prompt. ( -- )
    "( " in get " )" 3append
    H{ { background { 1 0.7 0.7 1 } } } format bl flush ;

: listen ( -- )
    listener-hook get call prompt.
    [ read-quot [ try ] [ bye ] if* ]
    [
        dup parse-error? [
            error-hook get call
        ] [
            rethrow
        ] if
    ] recover ;

: until-quit ( -- )
    quit-flag get
    [ quit-flag off ]
    [ listen until-quit ] if ; inline

: listener ( -- )
    [ until-quit ] with-interactive-vocabs ;

MAIN: listener

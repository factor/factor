! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables io kernel math memory namespaces
parser sequences strings io.styles io.streams.lines
io.streams.duplex vectors words generic system combinators
tuples continuations debugger ;
IN: listener

SYMBOL: quit-flag

SYMBOL: listener-hook

[ ] listener-hook set-global

GENERIC: parse-interactive ( stream -- quot/f )

: parse-interactive-step ( lines -- quot/f )
    [ parse-lines ] catch {
        { [ dup delegate unexpected-eof? ] [ 2drop f ] }
        { [ dup not ] [ drop ] }
        { [ t ] [ rethrow ] }
    } cond ;

: parse-interactive-loop  ( stream accum -- quot/f )
    over stream-readln dup [
        over push
        dup parse-interactive-step dup
        [ 2nip ] [ drop parse-interactive-loop ] if
    ] [
        3drop f
    ] if ;

M: line-reader parse-interactive
    [
        V{ } clone parse-interactive-loop in get
    ] with-scope in set ;

M: duplex-stream parse-interactive
    duplex-stream-in parse-interactive ;

: bye ( -- ) quit-flag on ;

: prompt. ( -- )
    "( " in get " )" 3append
    H{ { background { 1 0.7 0.7 1 } } } format bl flush ;

: listen ( -- )
    listener-hook get call prompt.
    [
        stdio get parse-interactive [ call ] [ bye ] if*
    ] try ;

: until-quit ( -- )
    quit-flag get
    [ quit-flag off ]
    [ listen until-quit ] if ; inline

: print-banner ( -- )
    "Factor " write version write
    " on " write os write "/" write cpu print ;

: listener ( -- )
    print-banner
    [ use [ clone ] change until-quit ] with-scope ;

MAIN: listener

! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables io kernel math memory namespaces
parser sequences strings io.styles io.streams.lines
io.streams.duplex vectors words generic system combinators
tuples continuations debugger definitions ;
IN: listener

SYMBOL: quit-flag

SYMBOL: listener-hook

[ ] listener-hook set-global

GENERIC: stream-read-quot ( stream -- quot/f )

: read-quot-step ( lines -- quot/f )
    [
        [ parse-lines in get ] with-compilation-unit in set
    ] catch {
        { [ dup delegate unexpected-eof? ] [ 2drop f ] }
        { [ dup not ] [ drop ] }
        { [ t ] [ rethrow ] }
    } cond ;

: read-quot-loop  ( stream accum -- quot/f )
    over stream-readln dup [
        over push
        dup read-quot-step dup
        [ 2nip ] [ drop read-quot-loop ] if
    ] [
        3drop f
    ] if ;

M: line-reader stream-read-quot
    V{ } clone read-quot-loop ;

M: duplex-stream stream-read-quot
    duplex-stream-in stream-read-quot ;

: read-quot ( -- quot ) stdio get stream-read-quot ;

: bye ( -- ) quit-flag on ;

: prompt. ( -- )
    "( " in get " )" 3append
    H{ { background { 1 0.7 0.7 1 } } } format bl flush ;

: listen ( -- )
    listener-hook get call prompt.
    [ read-quot [ call ] [ bye ] if* ] try ;

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

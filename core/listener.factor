! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: listener
USING: errors hashtables io kernel math memory namespaces
parser sequences strings styles vectors words generic ;

SYMBOL: quit-flag

SYMBOL: listener-hook

GENERIC: parse-interactive ( stream -- quot/f )

: (parse-interactive) ( stream stack -- quot/f )
    over stream-readln dup [
        over push \ (parse) with-datastack
        dup length 1 = [
            nip first >quotation
        ] [
            (parse-interactive)
        ] if
    ] [
        3drop f
    ] if ;

M: line-reader parse-interactive
    [
        [ V{ f } clone (parse-interactive) ] with-parser in get
    ] with-scope in set ;

M: duplex-stream parse-interactive
    duplex-stream-in parse-interactive ;

: bye ( -- ) quit-flag on ;

: prompt. ( -- )
    in get H{ { background { 1 0.7 0.7 1 } } } format bl flush ;

: listen ( -- )
    [ stdio get parse-interactive [ call ] [ bye ] if* ] try ;

: listener ( -- )
    quit-flag get
    [ quit-flag off ]
    [ prompt. listener-hook get call listen listener ] if ;

: print-banner ( -- )
    "Factor " write version write
    " on " write os write "/" write cpu print ;

IN: shells

: tty ( -- )
    [
        print-banner use [ clone ] change listener
    ] with-scope ;

! File: tools.continuations
! Version: 0.1
! DRI: Dave Carlton
! Description: Add breakpoint counter
! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors continuations kernel math namespaces
tools.continuations.private ;
IN: tools.continuations

SYMBOL: break-counter

: break-counter-get ( -- n )
    break-counter get ;

: break-count-zero ( -- )
    0 break-counter set ;

: break-count ( -- )
    break-counter get dup
    [  1 + ]
    [ drop 1 ] if
    break-counter set ;

: break-count= ( n -- )
    break-count
    break-counter get swap >=
    [     continuation callstack >>call
    break-hook get call( continuation -- continuation' )
    after-break  ]
    [ ] if ;

! \ break-count= t "break?" set-word-prop

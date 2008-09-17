! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words sequences lexer parser fry ;
IN: cpu.x86.syntax

: define-register ( name num size -- )
    [ "cpu.x86" create dup define-symbol ]
    [ dupd "register" set-word-prop ]
    [ "register-size" set-word-prop ]
    tri* ;

: define-registers ( names size -- )
    [ dup length ] dip '[ _ define-register ] 2each ;

: REGISTERS: ( -- )
    scan-word ";" parse-tokens swap define-registers ; parsing

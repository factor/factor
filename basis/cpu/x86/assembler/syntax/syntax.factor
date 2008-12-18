! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words words.symbol sequences lexer parser fry ;
IN: cpu.x86.assembler.syntax

: define-register ( name num size -- )
    [ "cpu.x86.assembler" create dup define-symbol ] 2dip
    [ dupd "register" set-word-prop ] dip
    "register-size" set-word-prop ;

: define-registers ( names size -- )
    '[ _ define-register ] each-index ;

: REGISTERS: ( -- )
    scan-word ";" parse-tokens swap define-registers ; parsing

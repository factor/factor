! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words sequences lexer parser fry ;
IN: cpu.x86.assembler.syntax

: define-register ( name num size -- )
    >r >r "cpu.x86.assembler" create dup define-symbol r> r>
    >r dupd "register" set-word-prop r>
    "register-size" set-word-prop ;

: define-registers ( names size -- )
    '[ _ define-register ] each-index ;

: REGISTERS: ( -- )
    scan-word ";" parse-tokens swap define-registers ; parsing

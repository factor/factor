! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words words.symbol sequences lexer parser fry
namespaces combinators assocs ;
IN: cpu.x86.assembler.syntax

SYMBOL: registers

registers [ H{ } clone ] initialize

: define-register ( name num size -- word )
    [ "cpu.x86.assembler.operands" create ] 2dip {
        [ 2drop ]
        [ 2drop define-symbol ]
        [ drop "register" set-word-prop ]
        [ nip "register-size" set-word-prop ]
    } 3cleave ;

: define-registers ( size names -- )
    [ swap '[ _ define-register ] map-index ] [ drop ] 2bi
    registers get set-at ;

SYNTAX: REGISTERS: scan-word ";" parse-tokens define-registers ;

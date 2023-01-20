! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel words words.symbol sequences lexer parser fry
namespaces combinators assocs math ;
IN: cpu.x86.assembler.syntax

SYMBOL: registers

registers [ H{ } clone ] initialize

: define-register ( name num size -- word )
    [ create-word-in ] 2dip {
        [ 2drop ]
        [ 2drop define-symbol ]
        [ drop "register" set-word-prop ]
        [ nip "register-size" set-word-prop ]
    } 3cleave ;

: (define-registers) ( names start size -- seq )
    '[ _ + _ define-register ] map-index ;

: define-registers ( names size -- )
    [ [ 0 ] dip (define-registers) ] keep registers get set-at ;

SYNTAX: REGISTERS:
    scan-number [ ";" parse-tokens ] dip define-registers ;

SYNTAX: HI-REGISTERS:
    scan-number [ ";" parse-tokens 4 ] dip (define-registers) drop ;

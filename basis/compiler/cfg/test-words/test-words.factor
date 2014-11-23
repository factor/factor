! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.instructions kernel math sequences ;
IN: compiler.cfg.test-words

: test-not-in-order ( -- nodes )
    V{
        ##load-tagged
        ##allot
        ##set-slot-imm
        ##load-reference
        ##allot
        ##set-slot-imm
        ##set-slot-imm
        ##set-slot-imm
        ##replace
    } [ [ new ] [ 2 * ] bi* >>insn# ] map-index ;

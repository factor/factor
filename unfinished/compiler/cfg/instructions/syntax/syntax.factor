! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.tuple classes.tuple.parser kernel words
make fry sequences parser ;
IN: compiler.cfg.instructions.syntax

TUPLE: insn ;

: INSN:
    parse-tuple-definition "regs" suffix
    [ dup tuple eq? [ drop insn ] when ] dip
    [ define-tuple-class ]
    [ 2drop save-location ]
    [ 2drop dup '[ f _ boa , ] define-inline ]
    3tri ; parsing

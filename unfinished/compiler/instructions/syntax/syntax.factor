! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.tuple classes.tuple.parser kernel words
make parser ;
IN: compiler.instructions.syntax

TUPLE: insn ;

: INSN:
    parse-tuple-definition
    [ dup tuple eq? [ drop insn ] when ] dip
    [ define-tuple-class ]
    [ 2drop save-location ]
    [ 2drop dup [ boa , ] curry define-inline ]
    3tri ; parsing

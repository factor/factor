! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.tuple classes.tuple.parser kernel words
make fry sequences parser accessors effects namespaces
combinators splitting classes.parser lexer quotations ;
IN: compiler.cfg.instructions.syntax

SYMBOLS: def use temp literal ;

SYMBOL: scalar-rep

TUPLE: insn-slot-spec type name rep ;

: parse-rep ( str/f -- rep )
    {
        { [ dup not ] [ ] }
        { [ dup "scalar-rep" = ] [ drop scalar-rep ] }
        [ "cpu.architecture" lookup ]
    } cond ;

: parse-insn-slot-spec ( type string -- spec )
    over [ "Missing type" throw ] unless
    "/" split1 parse-rep
    insn-slot-spec boa ;

: parse-insn-slot-specs ( seq -- specs )
    [
        f [
            {
                { "def:" [ drop def ] }
                { "use:" [ drop use ] }
                { "temp:" [ drop temp ] }
                { "literal:" [ drop literal ] }
                [ dupd parse-insn-slot-spec , ]
            } case
        ] reduce drop
    ] { } make ;

: find-def-slot ( slots -- slot/f )
    [ type>> def eq? ] find nip ;

: insn-def-slot ( class -- slot/f )
    "insn-slots" word-prop find-def-slot ;

: insn-use-slots ( class -- slots )
    "insn-slots" word-prop [ type>> use eq? ] filter ;

: insn-temp-slots ( class -- slots )
    "insn-slots" word-prop [ type>> temp eq? ] filter ;

! We cannot reference words in compiler.cfg.instructions directly
! since that would create circularity.
: insn-classes-word ( -- word )
    "insn-classes" "compiler.cfg.instructions" lookup ;

: insn-word ( -- word )
    "insn" "compiler.cfg.instructions" lookup ;

: pure-insn-word ( -- word )
    "pure-insn" "compiler.cfg.instructions" lookup ;

: insn-effect ( word -- effect )
    boa-effect in>> but-last { } <effect> ;

: define-insn-tuple ( class superclass specs -- )
    [ name>> ] map "insn#" suffix define-tuple-class ;

: define-insn-ctor ( class specs -- )
    [ dup '[ _ ] [ f ] [ boa , ] surround ] dip
    [ name>> ] map { } <effect> define-declared ;

: define-insn ( class superclass specs -- )
    parse-insn-slot-specs {
        [ nip "insn-slots" set-word-prop ]
        [ 2drop insn-classes-word get push ]
        [ define-insn-tuple ]
        [ 2drop save-location ]
        [ nip define-insn-ctor ]
    } 3cleave ;

SYNTAX: INSN: CREATE-CLASS insn-word ";" parse-tokens define-insn ;

SYNTAX: PURE-INSN: CREATE-CLASS pure-insn-word ";" parse-tokens define-insn ;

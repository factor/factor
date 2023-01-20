! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.parser classes.tuple combinators
effects kernel lexer make namespaces parser sequences
splitting words ;
IN: compiler.cfg.instructions.syntax

SYMBOLS: def use temp literal ;

SYMBOL: scalar-rep

TUPLE: insn-slot-spec type name rep ;

: parse-rep ( str/f -- rep )
    {
        { [ dup not ] [ ] }
        { [ dup "scalar-rep" = ] [ drop scalar-rep ] }
        [ "cpu.architecture" lookup-word ]
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

: insn-def-slots ( class -- slot/f )
    "insn-slots" word-prop [ type>> def eq? ] filter ;

: insn-use-slots ( class -- slots )
    "insn-slots" word-prop [ type>> use eq? ] filter ;

: insn-temp-slots ( class -- slots )
    "insn-slots" word-prop [ type>> temp eq? ] filter ;

! We cannot reference words in compiler.cfg.instructions directly
! since that would create circularity.
: insn-classes-word ( -- word )
    "insn-classes" "compiler.cfg.instructions" lookup-word ;

: insn-word ( -- word )
    "insn" "compiler.cfg.instructions" lookup-word ;

: vreg-insn-word ( -- word )
    "vreg-insn" "compiler.cfg.instructions" lookup-word ;

: flushable-insn-word ( -- word )
    "flushable-insn" "compiler.cfg.instructions" lookup-word ;

: foldable-insn-word ( -- word )
    "foldable-insn" "compiler.cfg.instructions" lookup-word ;

: insn-effect ( word -- effect )
    boa-effect in>> but-last { } <effect> ;

: uses-vregs? ( specs -- ? )
    [ type>> { def use temp } member-eq? ] any? ;

: define-insn-tuple ( class superclass specs -- )
    [ name>> ] map "insn#" suffix define-tuple-class ;

: insn-ctor-name ( word -- name )
    name>> "," append ;

: define-insn-ctor ( class specs -- )
    [ [ insn-ctor-name create-word-in ] [ '[ _ ] [ f ] [ boa , ] surround ] bi ] dip
    [ name>> ] map { } <effect> define-declared ;

: define-insn ( class superclass specs -- )
    parse-insn-slot-specs
    {
        [ nip "insn-slots" set-word-prop ]
        [ 2drop insn-classes-word get push ]
        [ define-insn-tuple ]
        [ 2drop save-location ]
        [ nip define-insn-ctor ]
    } 3cleave ;

SYNTAX: INSN:
    scan-new-class insn-word ";" parse-tokens define-insn ;

SYNTAX: VREG-INSN:
    scan-new-class vreg-insn-word ";" parse-tokens define-insn ;

SYNTAX: FLUSHABLE-INSN:
    scan-new-class flushable-insn-word ";" parse-tokens define-insn ;

SYNTAX: FOLDABLE-INSN:
    scan-new-class foldable-insn-word ";" parse-tokens define-insn ;

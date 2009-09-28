! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays kernel layouts math
namespaces sequences combinators splitting parser effects
words cpu.architecture compiler.cfg.registers
compiler.cfg.instructions compiler.cfg.instructions.syntax ;
IN: compiler.cfg.hats

<<

<PRIVATE

: hat-name ( insn -- word )
    name>> "##" ?head drop "^^" prepend create-in ;

: hat-quot ( insn -- quot )
    [
        "insn-slots" word-prop [ ] [
            type>> {
                { def [ [ next-vreg dup ] ] }
                { temp [ [ next-vreg ] ] }
                [ drop [ ] ]
            } case swap [ dip ] curry compose
        ] reduce
    ] keep suffix ;

: hat-effect ( insn -- effect )
    "insn-slots" word-prop
    [ type>> { def temp } memq? not ] filter [ name>> ] map
    { "vreg" } <effect> ;

: define-hat ( insn -- )
    [ hat-name ] [ hat-quot ] [ hat-effect ] tri define-inline ;

PRIVATE>

insn-classes get [
    dup [ insn-def-slot ] [ name>> "##" head? ] bi and
    [ define-hat ] [ drop ] if
] each

>>

: ^^load-literal ( obj -- dst )
    [ next-vreg dup ] dip {
        { [ dup not ] [ drop \ f tag-number ##load-immediate ] }
        { [ dup fixnum? ] [ tag-fixnum ##load-immediate ] }
        [ ##load-reference ]
    } cond ;

: ^^unbox-c-ptr ( src class -- dst )
    [ next-vreg dup ] 2dip next-vreg ##unbox-c-ptr ;

: ^^allot-tuple ( n -- dst )
    2 + cells tuple ^^allot ;

: ^^allot-array ( n -- dst )
    2 + cells array ^^allot ;

: ^^allot-byte-array ( n -- dst )
    2 cells + byte-array ^^allot ;

: ^^offset>slot ( slot -- vreg' )
    cell 4 = [ 1 ^^shr-imm ] [ any-rep ^^copy ] if ;

: ^^tag-offset>slot ( slot tag -- vreg' )
    [ ^^offset>slot ] dip ^^sub-imm ;

: ^^tag-fixnum ( src -- dst )
    tag-bits get ^^shl-imm ;

: ^^untag-fixnum ( src -- dst )
    tag-bits get ^^sar-imm ;

! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays byte-arrays classes.algebra
combinators.short-circuit kernel layouts math namespaces
sequences combinators splitting parser effects words
cpu.architecture compiler.constants compiler.cfg.registers
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
    [ type>> { def temp } member-eq? not ] filter [ name>> ] map
    { "vreg" } <effect> ;

: define-hat ( insn -- )
    [ hat-name ] [ hat-quot ] [ hat-effect ] tri define-inline ;

PRIVATE>

insn-classes get [
    dup [ insn-def-slots length 1 = ] [ name>> "##" head? ] bi and
    [ define-hat ] [ drop ] if
] each

>>

: ^^load-literal ( obj -- dst )
    dup fixnum? [ ^^load-integer ] [ ^^load-reference ] if ;

: ^^offset>slot ( slot -- vreg' )
    cell 4 = 2 3 ? ^^shl-imm ;

: ^^unbox-f ( src -- dst )
    drop 0 ^^load-literal ;

: ^^unbox-byte-array ( src -- dst )
    ^^tagged>integer byte-array-offset ^^add-imm ;

: ^^unbox-c-ptr ( src class -- dst )
    {
        { [ dup \ f class<= ] [ drop ^^unbox-f ] }
        { [ dup alien class<= ] [ drop ^^unbox-alien ] }
        { [ dup byte-array class<= ] [ drop ^^unbox-byte-array ] }
        [ drop ^^unbox-any-c-ptr ]
    } cond ;

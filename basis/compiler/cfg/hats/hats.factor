! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien byte-arrays classes.algebra combinators
combinators.short-circuit compiler.cfg.instructions
compiler.cfg.instructions.syntax compiler.cfg.registers
compiler.constants effects kernel layouts math namespaces parser
sequences splitting words ;
IN: compiler.cfg.hats

<<

<PRIVATE

: hat-name ( insn -- word )
    name>> "##" ?head drop "^^" prepend create-word-in ;

: hat-quot ( insn -- quot )
    [
        "insn-slots" word-prop [ ] [
            type>> {
                { def [ [ next-vreg dup ] ] }
                { temp [ [ next-vreg ] ] }
                [ drop [ ] ]
            } case swap [ dip ] curry compose
        ] reduce
    ] keep insn-ctor-name "compiler.cfg.instructions" lookup-word suffix ;

: hat-effect ( insn -- effect )
    "insn-slots" word-prop
    [ type>> { def temp } member-eq? ] reject [ name>> ] map
    { "vreg" } <effect> ;

: define-hat ( insn -- )
    [ hat-name ] [ hat-quot ] [ hat-effect ] tri define-inline ;

PRIVATE>

insn-classes get [
    dup { [ insn-def-slots length 1 = ] [ name>> "##" head? ] } 1&&
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

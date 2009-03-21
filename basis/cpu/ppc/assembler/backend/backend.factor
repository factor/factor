! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.codegen.fixup cpu.architecture
compiler.constants kernel namespaces make sequences words math
math.bitwise io.binary parser lexer ;
IN: cpu.ppc.assembler.backend

: insn ( operand opcode -- ) { 26 0 } bitfield , ;

: a-insn ( d a b c xo rc opcode -- )
    [ { 0 1 6 11 16 21 } bitfield ] dip insn ;

: b-insn ( bo bi bd aa lk opcode -- )
    [ { 0 1 2 16 21 } bitfield ] dip insn ;

: s>u16 ( s -- u ) HEX: ffff bitand ;

: d-insn ( d a simm opcode -- )
    [ s>u16 { 0 16 21 } bitfield ] dip insn ;

: define-d-insn ( word opcode -- )
    [ d-insn ] curry (( d a simm -- )) define-declared ;

SYNTAX: D: CREATE scan-word define-d-insn ;

: sd-insn ( d a simm opcode -- )
    [ s>u16 { 0 21 16 } bitfield ] dip insn ;

: define-sd-insn ( word opcode -- )
    [ sd-insn ] curry (( d a simm -- )) define-declared ;

SYNTAX: SD: CREATE scan-word define-sd-insn ;

: i-insn ( li aa lk opcode -- )
    [ { 0 1 0 } bitfield ] dip insn ;

: x-insn ( a s b rc xo opcode -- )
    [ { 1 0 11 21 16 } bitfield ] dip insn ;

: (X) ( -- word quot )
    CREATE scan-word scan-word scan-word [ x-insn ] 3curry ;

SYNTAX: X: (X) (( a s b -- )) define-declared ;

: (1) ( quot -- quot' ) [ 0 ] prepose ;

SYNTAX: X1: (X) (1) (( a s -- )) define-declared ;

: xfx-insn ( d spr xo opcode -- )
    [ { 1 11 21 } bitfield ] dip insn ;

: CREATE-MF ( -- word ) scan "MF" prepend create-in ;

SYNTAX: MFSPR:
    CREATE-MF scan-word 5 shift [ 339 31 xfx-insn ] curry
    (( d -- )) define-declared ;

: CREATE-MT ( -- word ) scan "MT" prepend create-in ;

SYNTAX: MTSPR:
    CREATE-MT scan-word 5 shift [ 467 31 xfx-insn ] curry
    (( d -- )) define-declared ;

: xo-insn ( d a b oe rc xo opcode -- )
    [ { 1 0 10 11 16 21 } bitfield ] dip insn ;

: (XO) ( -- word quot )
    CREATE scan-word scan-word scan-word scan-word
    [ xo-insn ] 2curry 2curry ;

SYNTAX: XO: (XO) (( a s b -- )) define-declared ;

SYNTAX: XO1: (XO) (1) (( a s -- )) define-declared ;

GENERIC# (B) 2 ( dest aa lk -- )
M: integer (B) 18 i-insn ;
M: word (B) [ 0 ] 2dip (B) rc-relative-ppc-3 rel-word ;
M: label (B) [ 0 ] 2dip (B) rc-relative-ppc-3 label-fixup ;

GENERIC: BC ( a b c -- )
M: integer BC 0 0 16 b-insn ;
M: word BC [ 0 BC ] dip rc-relative-ppc-2 rel-word ;
M: label BC [ 0 BC ] dip rc-relative-ppc-2 label-fixup ;

: CREATE-B ( -- word ) scan "B" prepend create-in ;

SYNTAX: BC:
    CREATE-B scan-word scan-word
    [ rot BC ] 2curry (( c -- )) define-declared ;

SYNTAX: B:
    CREATE-B scan-word scan-word scan-word scan-word scan-word
    [ b-insn ] curry curry curry curry curry
    (( bo -- )) define-declared ;

! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler errors inference kernel lists math
memory namespaces sequences strings vectors words ;

! Compile a VOP.
GENERIC: generate-node ( vop -- )

: generate-code ( word linear -- length )
    compiled-offset >r
    compile-aligned
    swap save-xt
    [ [ generate-node ] each ] each
    compile-aligned
    compiled-offset r> - ;

: generate-reloc ( -- length )
    relocation-table get
    dup [ compile-cell ] each
    length cell * ;

: (generate) ( word linear -- )
    #! Compile a word definition from linear IR.
    { } clone relocation-table set
    begin-assembly swap >r >r
        generate-code
        generate-reloc
    r> set-compiled-cell
    r> set-compiled-cell ;

SYMBOL: previous-offset

: generate ( word linear -- )
    #! If generation fails, reset compiled offset.
    [
        compiled-offset previous-offset set
        (generate)
    ] [
        [
            previous-offset get set-compiled-offset
            rethrow
        ] when*
    ] catch ;

! A few VOPs have trivial generators.

M: %label generate-node ( vop -- )
    vop-label save-xt ;

M: %end-dispatch generate-node ( vop -- ) drop ;

: compile-target ( word -- ) 0 compile-cell absolute ;

M: %target-label generate-node vop-label compile-target ;

M: %target generate-node
    vop-label dup postpone-word  compile-target ;

GENERIC: v>operand

M: integer v>operand tag-bits shift ;

M: f v>operand address ;

: dest/src ( vop -- dest src )
    dup 0 vop-out v>operand swap 0 vop-in v>operand ;

! These constants must match native/card.h
: card-bits 7 ;
: card-mark HEX: 80 ;

: shift-add ( by -- n )
    #! Used in fixnum-shift overflow check.
    1 swap cell 8 * swap 1 - - shift ;

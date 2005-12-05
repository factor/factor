! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler errors inference kernel
kernel-internals lists math memory namespaces sequences strings
vectors words ;

! Compile a VOP.
GENERIC: generate-node ( vop -- )

: set-stack-reserve ( linear -- )
    #! The %prologue node contains the maximum stack reserve of
    #! all VOPs. The precise meaning of stack reserve is
    #! platform-specific.
    0 [ 0 [ stack-reserve max ] reduce max ] reduce
    \ stack-reserve set ;

: generate-code ( word linear -- length )
    compiled-offset >r
    compile-aligned
    swap save-xt
    [ [ dup [ generate-node ] with-vop ] each ] each
    compile-aligned
    compiled-offset r> - ;

: generate-reloc ( -- length )
    relocation-table get
    dup [ assemble-cell ] each
    length cell * ;

: (generate) ( word linear -- )
    #! Compile a word definition from linear IR.
    V{ } clone relocation-table set
    dup set-stack-reserve
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
        previous-offset get set-compiled-offset
        rethrow
    ] recover ;

! A few VOPs have trivial generators.

M: %label generate-node ( vop -- )
    vop-label save-xt ;

M: %end-dispatch generate-node ( vop -- ) drop ;

: compile-target ( word -- ) 0 assemble-cell absolute-cell ;

M: %target-label generate-node vop-label compile-target ;

M: %target generate-node
    vop-label dup postpone-word  compile-target ;

M: %parameters generate-node ( vop -- ) drop ;

: dest/src ( vop -- dest src )
    dup 0 vop-out v>operand swap 0 vop-in v>operand ;

! These constants must match native/card.h
: card-bits 7 ;
: card-mark HEX: 80 ;

: shift-add ( by -- n )
    #! Used in fixnum-shift overflow check.
    1 swap cell 8 * swap 1- - shift ;

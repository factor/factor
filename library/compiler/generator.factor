! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler errors inference kernel
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
    length cells ;

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

M: %target-label generate-node ( vop -- )
    drop label 0 assemble-cell absolute-cell ;

M: %parameters generate-node ( vop -- ) drop ;

M: %parameter generate-node ( vop -- ) drop ;

M: %alien-invoke generate-node
    #! call a C function.
    drop 0 input 1 input load-library compile-c-call ;

: dest/src ( -- dest src ) 0 output-operand 0 input-operand ;

! These constants must match native/card.h
: card-bits 7 ;
: card-mark HEX: 80 ;

: shift-add ( by -- n )
    #! Used in fixnum-shift overflow check.
    >r 1 cell-bits r> 1- - shift ;

! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: arrays errors generic assocs hashtables inference
kernel kernel-internals math namespaces sequences words
quotations strings alien ;

: no-stack-frame -1 ; inline

TUPLE: frame-required n ;

: frame-required ( n -- ) <frame-required> , ;

: stack-frame-size ( code -- n )
    no-stack-frame [
        dup frame-required? [ frame-required-n max ] [ drop ] if
    ] reduce ;

GENERIC: fixup* ( frame-size obj -- frame-size )

: compiled-offset ( -- n ) building get length code-format * ;

TUPLE: label offset ;

C: label ( -- label ) ;

M: label fixup*
    compiled-offset swap set-label-offset ;

: define-label ( name -- ) <label> swap set ;

: resolve-label ( label/name -- ) dup string? [ get ] when , ;

: if-stack-frame ( frame-size quot -- )
    over no-stack-frame = [ 2drop ] [ call ] if ; inline

M: word fixup*
    {
        { %prologue-later [ dup [ %prologue ] if-stack-frame ] }
        { %epilogue-later [ dup [ %epilogue ] if-stack-frame ] }
    } case ;

SYMBOL: relocation-table
SYMBOL: label-table

! Relocation classes
C-ENUM:
    rc-absolute-cell
    rc-absolute
    rc-relative
    rc-absolute-ppc-2/2
    rc-relative-ppc-2
    rc-relative-ppc-3
    rc-relative-arm-3
    rc-indirect-arm
    rc-indirect-arm-pc ;

: rc-absolute? ( n -- ? )
    dup rc-absolute-cell =
    over rc-absolute =
    rot rc-absolute-ppc-2/2 = or or ;

! Relocation types
C-ENUM:
    rt-primitive
    rt-dlsym
    rt-literal
    rt-dispatch
    rt-xt
    rt-label ;

TUPLE: label-fixup label class ;

: label-fixup ( label class -- ) <label-fixup> , ;

M: label-fixup fixup*
    dup label-fixup-class rc-absolute?
    [ "Absolute labels not supported" throw ] when
    dup label-fixup-label swap label-fixup-class
    compiled-offset 4 - rot 3array label-table get push ;

TUPLE: rel-fixup arg class type ;

: rel-fixup ( arg class type -- )
    <rel-fixup> , ;

: (rel-fixup) ( arg class type offset -- pair )
    #! Write a relocation instruction for the runtime image
    #! loader.
    pick rc-absolute-cell = cell 4 ? -
    >r { 0 8 16 } bitfield r>
    2array ;

M: rel-fixup fixup*
    dup rel-fixup-arg
    over rel-fixup-class
    rot rel-fixup-type
    compiled-offset (rel-fixup)
    relocation-table get push-all ;

M: frame-required fixup* drop ;

M: integer fixup* , ;

: push-new* ( obj table -- n )
    2dup [ eq? ] find-with drop [
        2nip
    ] [
        dup length >r push r>
    ] if* ;

SYMBOL: literal-table

: add-literal ( obj -- n ) literal-table get push-new* ;

SYMBOL: word-table

: add-word ( word -- n ) word-table get push-new* ;

: string>symbol ( str -- alien )
    #! On Windows CE the symbol name has to be unicode.
    wince? [ string>u16-alien ] [ string>char-alien ] if ;

: add-dlsym-literals ( symbol dll -- )
    >r string>symbol r> 2array literal-table get push-all ;

: rel-dlsym ( name dll class -- )
    >r literal-table get length >r
    add-dlsym-literals
    r> r> rt-dlsym rel-fixup ;

: rel-dispatch ( word-table# class -- ) rt-dispatch rel-fixup ;

G: rel-word ( word class -- ) 1 standard-combination ;

M: primitive rel-word ( word class -- )
    >r word-primitive r> rt-primitive rel-fixup ;

M: word rel-word ( word class -- )
    >r add-word r> rt-xt rel-fixup ;

: rel-literal ( literal class -- )
    >r add-literal r> rt-literal rel-fixup ;

: init-fixup ( -- )
    V{ } clone relocation-table set
    V{ } clone label-table set ;

: generate-labels ( -- labels )
    label-table get [ first3 label-offset 3array ] map concat ;

: fixup ( code -- relocation-table label-table code )
    [
        init-fixup
        dup stack-frame-size swap [ fixup* ] each drop
        relocation-table get
        generate-labels
    ] V{ } make ;

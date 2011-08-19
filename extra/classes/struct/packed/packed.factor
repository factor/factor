! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types classes.struct
classes.struct.private kernel locals math sequences slots
words ;

IN: classes.struct.packed

<PRIVATE

CONSTANT: ALIGNMENT 1

GENERIC: compute-packed-offset ( offset class -- offset' )

M: struct-slot-spec compute-packed-offset
    [ ALIGNMENT 8 * align ] dip
    [ [ 8 /i ] dip offset<< ] [ type>> heap-size 8 * + ] 2bi ;

M: struct-bit-slot-spec compute-packed-offset
    [ offset<< ] [ bits>> + ] 2bi ;

: compute-packed-offsets ( slots -- size )
    0 [ compute-packed-offset ] reduce 8 align 8 /i ;

:: (define-packed-class) ( class slots offsets-quot -- )
    slots empty? [ struct-must-have-slots ] when
    class redefine-struct-tuple-class
    slots make-slots dup check-struct-slots :> slot-specs
    slot-specs offsets-quot call :> unaligned-size
    ALIGNMENT :> alignment
    unaligned-size :> size

    class  slot-specs  size  alignment  c-type-for-class :> c-type

    c-type class typedef
    class slot-specs define-accessors
    class size "struct-size" set-word-prop
    class dup make-struct-prototype "prototype" set-word-prop
    class (struct-methods) ; inline

: define-packed-struct-class ( class slots -- )
    [ compute-packed-offsets ] (define-packed-class) ;

PRIVATE>

SYNTAX: PACKED-STRUCT:
    parse-struct-definition define-packed-struct-class ;



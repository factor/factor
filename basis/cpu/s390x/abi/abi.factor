! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays classes.struct combinators
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions cpu.architecture kernel layouts
locals math math.order namespaces sequences system words ;
QUALIFIED-WITH: alien.c-types c
IN: cpu.s390x.abi

! IBM ELF ABI 1.7 sections 1.2.3 and 1.2.5: one recursively nested FP
! member in a 4/8-byte aggregate uses an FPR of the aggregate width.
! Other 1/2/4/8-byte aggregates use a right-aligned GPR;
! larger aggregates pass by address. Every aggregate return uses a buffer.
GENERIC: single-fp-rep ( c-type -- rep/f )
M: object single-fp-rep
    c-type-rep dup { float-rep double-rep } member? [ drop f ] unless ;
M: array single-fp-rep drop f ;
M:: struct-c-type single-fp-rep ( c-type -- rep/f )
    c-type boxed-class>> "union-struct" word-prop [ f ] [
        c-type fields>> dup length 1 = [
            first dup struct-bit-slot-spec? [ drop f ]
            [ type>> lookup-c-type single-fp-rep ] if
        ] [ drop f ] if
    ] if [
        c-type heap-size {
            { 4 [ float-rep ] } { 8 [ double-rep ] } [ drop f ]
        } case
    ] [ f ] if ;
: fp-aggregate-rep ( c-type -- rep/f ) base-type single-fp-rep ;
: small-integer-aggregate? ( c-type -- ? )
    heap-size { 1 2 4 8 } member? ;
! C99 complex arguments are indirect even when complex-float fits a GPR.
M: s390x value-struct?
    dup c-type-boxed-class complex eq? [ drop f ] [
        [ fp-aggregate-rep >boolean ] [ small-integer-aggregate? ] bi or
    ] if ;
M: s390x return-struct-in-registers? drop f ;
M:: s390x flatten-struct-type ( c-type -- reps )
    c-type fp-aggregate-rep [
        dup rep-size f f rot 4array 1array
    ] [
        c-type heap-size cell align cell /i { int-rep f f } <array>
    ] if* record-reg-reps ;
M:: s390x struct-components ( reps c-type -- offsets types )
    c-type fp-aggregate-rep [
        float-rep eq? c:float c:double ? base-type 1array { 0 } swap
    ] [
        c-type small-integer-aggregate? [
            c-type heap-size {
                { 1 [ c:uchar ] } { 2 [ c:ushort ] }
                { 4 [ c:uint ] } { 8 [ c:ulonglong ] }
            } case base-type 1array { 0 } swap
        ] [ reps c-type integer-struct-components ] if
    ] if* ;
M:: s390x unbox-struct-parameter ( src c-type -- vregs reps )
    c-type value-struct? [ src c-type unbox ] [
        c-type heap-size c-type c-type-align cell max f ^^local-allot :> buffer
        src ^^unbox-any-c-ptr :> pointer
        pointer buffer c-type copy-struct-data
        buffer 1array { { int-rep f f } } record-reg-reps
    ] if ;

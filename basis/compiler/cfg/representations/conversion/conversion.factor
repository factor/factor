! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays combinators compiler.cfg.instructions
compiler.cfg.registers compiler.constants cpu.architecture
kernel layouts math namespaces ;
IN: compiler.cfg.representations.conversion

ERROR: bad-conversion dst src dst-rep src-rep ;

GENERIC: rep>tagged ( dst src rep -- )
GENERIC: tagged>rep ( dst src rep -- )

M: int-rep rep>tagged ( dst src rep -- )
    drop tag-bits get ##shl-imm, ;

M: int-rep tagged>rep ( dst src rep -- )
    drop tag-bits get ##sar-imm, ;

M:: float-rep rep>tagged ( dst src rep -- )
    double-rep next-vreg-rep :> temp
    temp src ##single>double-float,
    dst temp double-rep rep>tagged ;

M:: float-rep tagged>rep ( dst src rep -- )
    double-rep next-vreg-rep :> temp
    temp src double-rep tagged>rep
    dst temp ##double>single-float, ;

M:: double-rep rep>tagged ( dst src rep -- )
    dst 16 float int-rep next-vreg-rep ##allot,
    src dst float-offset double-rep f ##store-memory-imm, ;

M: double-rep tagged>rep
    drop float-offset double-rep f ##load-memory-imm, ;

M:: vector-rep rep>tagged ( dst src rep -- )
    tagged-rep next-vreg-rep :> temp
    dst 16 2 cells + byte-array int-rep next-vreg-rep ##allot,
    temp 16 tag-fixnum ##load-tagged,
    temp dst 1 byte-array type-number ##set-slot-imm,
    src dst byte-array-offset rep f ##store-memory-imm, ;

M: vector-rep tagged>rep
    [ byte-array-offset ] dip f ##load-memory-imm, ;

M:: scalar-rep rep>tagged ( dst src rep -- )
    tagged-rep next-vreg-rep :> temp
    temp src rep ##scalar>integer,
    dst temp int-rep rep>tagged ;

M:: scalar-rep tagged>rep ( dst src rep -- )
    tagged-rep next-vreg-rep :> temp
    temp src int-rep tagged>rep
    dst temp rep ##integer>scalar, ;

GENERIC: rep>int ( dst src rep -- )
GENERIC: int>rep ( dst src rep -- )

M: scalar-rep rep>int ( dst src rep -- )
    ##scalar>integer, ;

M: scalar-rep int>rep ( dst src rep -- )
    ##integer>scalar, ;

: emit-conversion ( dst src dst-rep src-rep -- )
    {
        { [ 2dup eq? ] [ drop ##copy, ] }
        { [ dup tagged-rep? ] [ drop tagged>rep ] }
        { [ over tagged-rep? ] [ nip rep>tagged ] }
        { [ dup int-rep? ] [ drop int>rep ] }
        { [ over int-rep? ] [ nip rep>int ] }
        [
            2dup 2array {
                { { double-rep float-rep } [ 2drop ##single>double-float, ] }
                { { float-rep double-rep } [ 2drop ##double>single-float, ] }
                ! Punning SIMD vector types? Naughty naughty! But
                ! it is allowed... otherwise bail out.
                [
                    drop 2dup [ reg-class-of ] bi@ eq?
                    [ drop ##copy, ] [ bad-conversion ] if
                ]
            } case
        ]
    } cond ;

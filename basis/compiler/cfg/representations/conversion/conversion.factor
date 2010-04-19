! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays combinators compiler.cfg.instructions
compiler.cfg.registers compiler.constants cpu.architecture
kernel layouts locals math namespaces ;
IN: compiler.cfg.representations.conversion

ERROR: bad-conversion dst src dst-rep src-rep ;

GENERIC: emit-box ( dst src rep -- )
GENERIC: emit-unbox ( dst src rep -- )

M: int-rep emit-box ( dst src rep -- )
    drop tag-bits get ##shl-imm ;

M: int-rep emit-unbox ( dst src rep -- )
    drop tag-bits get ##sar-imm ;

M:: float-rep emit-box ( dst src rep -- )
    double-rep next-vreg-rep :> temp
    temp src ##single>double-float
    dst temp double-rep emit-box ;

M:: float-rep emit-unbox ( dst src rep -- )
    double-rep next-vreg-rep :> temp
    temp src double-rep emit-unbox
    dst temp ##double>single-float ;

M: double-rep emit-box
    drop
    [ drop 16 float tagged-rep next-vreg-rep ##allot ]
    [ float-offset swap ##set-alien-double ]
    2bi ;

M: double-rep emit-unbox
    drop float-offset ##alien-double ;

M:: vector-rep emit-box ( dst src rep -- )
    tagged-rep next-vreg-rep :> temp
    dst 16 2 cells + byte-array tagged-rep next-vreg-rep ##allot
    temp 16 tag-fixnum ##load-immediate
    temp dst 1 byte-array type-number ##set-slot-imm
    dst byte-array-offset src rep ##set-alien-vector ;

M: vector-rep emit-unbox
    [ byte-array-offset ] dip ##alien-vector ;

M:: scalar-rep emit-box ( dst src rep -- )
    tagged-rep next-vreg-rep :> temp
    temp src rep ##scalar>integer
    dst temp int-rep emit-box ;

M:: scalar-rep emit-unbox ( dst src rep -- )
    tagged-rep next-vreg-rep :> temp
    temp src int-rep emit-unbox
    dst temp rep ##integer>scalar ;

: emit-conversion ( dst src dst-rep src-rep -- )
    {
        { [ 2dup eq? ] [ drop ##copy ] }
        { [ dup tagged-rep eq? ] [ drop emit-unbox ] }
        { [ over tagged-rep eq? ] [ nip emit-box ] }
        [
            2dup 2array {
                { { double-rep float-rep } [ 2drop ##single>double-float ] }
                { { float-rep double-rep } [ 2drop ##double>single-float ] }
                ! Punning SIMD vector types? Naughty naughty! But
                ! it is allowed... otherwise bail out.
                [
                    drop 2dup [ reg-class-of ] bi@ eq?
                    [ drop ##copy ] [ bad-conversion ] if
                ]
            } case
        ]
    } cond ;

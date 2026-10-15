! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! GNU/Linux m68k uses stack arguments, D0:D1 integer results and FP0
! hardware floating point results. A1 carries an indirect aggregate result.
USING: alien alien.c-types arrays compiler.cfg.builder.alien.boxing cpu.architecture kernel
sequences system words ;
IN: cpu.m68k.abi

M: m68k.32 param-regs
    drop { { int-regs { } } { float-regs { } } } ;
M: m68k.32 return-regs
    { { int-regs { 0 1 } } { float-regs { 0 } } } ;
M: m68k.32 return-regs-for-type
    ! Encoded C strings have an object class but still return a C pointer.
    base-type c-type-class c-ptr eq?
    [ { { int-regs { 8 } } { float-regs { 0 } } } ]
    [ M\ m68k.32 return-regs execute( -- regs ) ] if ;
M: m68k.32 return-struct-in-registers? drop f ;
M: m68k.32 value-struct? drop t ;
M: m68k.32 struct-return-on-stack? f ;
M: m68k.32 struct-return-register os netbsd? [ 8 ] [ 9 ] if ;
M: m68k.32 return-struct-pointer? f ;
M: m68k.32 dummy-stack-params? f ;
M: m68k.32 dummy-int-params? f ;
M: m68k.32 dummy-fp-params? f ;
M: m68k.32 long-long-on-stack? t ;
M: m68k.32 long-long-odd-register? f ;
M: m68k.32 float-right-align-on-stack? f ;
M: m68k.32 flatten-struct-type
    call-next-method [ first t f 3array ] map ;

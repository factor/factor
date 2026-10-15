! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! NetBSD GCC's default ABI uses stack arguments and native F/D returns
! in R0:R1. All aggregate returns use R1 as an indirect result pointer,
! including aggregates of one byte; the callee returns that pointer in R0.
USING: arrays compiler.cfg.builder.alien.boxing cpu.architecture kernel sequences system ;
IN: cpu.vax.abi

M: vax.32 param-regs drop { { int-regs { } } { float-regs { } } } ;
M: vax.32 return-regs { { int-regs { 0 1 } } { float-regs { 0 } } } ;
M: vax.32 return-struct-in-registers? drop f ;
M: vax.32 value-struct? drop t ;
M: vax.32 struct-return-on-stack? f ;
M: vax.32 struct-return-register 1 ;
M: vax.32 return-struct-pointer? t ;
M: vax.32 dummy-stack-params? f ;
M: vax.32 dummy-int-params? f ;
M: vax.32 dummy-fp-params? f ;
M: vax.32 long-long-on-stack? t ;
M: vax.32 long-long-odd-register? f ;
M: vax.32 float-right-align-on-stack? f ;
M: vax.32 flatten-struct-type call-next-method [ first t f 3array ] map ;

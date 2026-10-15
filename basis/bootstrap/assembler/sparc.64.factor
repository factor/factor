! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.constants cpu.sparc.assembler
kernel layouts locals math math.bitwise namespaces parser sequences ;
IN: bootstrap.assembler.sparc

8 \ cell set
big-endian on
: fsr-register ( -- n ) 1 ;
: cell-size ( -- n ) 8 ;
: stack-bias ( -- n ) 2047 ;
: stack-frame ( -- n ) 176 ;
: frame-link-offset ( -- n ) 2159 ;
: frame-return-offset ( -- n ) 2167 ;
: flush-windows ( -- ) 0x81580000 emit-insn ;
: load-cell ( rd base offset -- ) LDX ;
: store-cell ( rd base offset -- ) STX ;
: load-cell-x ( rd base index -- ) LDXR ;
: shift-right ( rd src n -- ) SRAXI ;
: shift-left ( rd src n -- ) SLLXI ;
: load-address ( rd -- class ) 23 0 SET64 rc-native-1 ;
: branch ( condition displacement -- ) 2 t f BPcc NOP ;

:: extended-shift ( rd a b op3 -- )
    0x80001000 rd R 25 shift bitor a R 14 shift bitor
    op3 19 shift bitor b R bitor emit-insn ;
: extended-SLL ( rd a b -- ) 37 extended-shift ;
: extended-SRA ( rd a b -- ) 39 extended-shift ;

: multiply ( rd a b -- ) MULX ;
: divide ( rd a b -- ) SDIVX ;
: shift-left-reg ( rd a b -- ) extended-SLL ;
: shift-right-reg ( rd a b -- ) extended-SRA ;

: product-quotient-check ( -- ) 12 11 9 divide 0 12 8 SUBcc ;
<< "resource:basis/bootstrap/assembler/sparc.factor" parse-file suffix! >> call

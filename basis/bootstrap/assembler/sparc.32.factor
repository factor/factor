! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.constants cpu.sparc.assembler
kernel layouts locals namespaces parser sequences ;
IN: bootstrap.assembler.sparc

4 \ cell set
big-endian on
: fsr-register ( -- n ) 0 ;
: cell-size ( -- n ) 4 ;
: stack-bias ( -- n ) 0 ;
: stack-frame ( -- n ) 96 ;
: frame-link-offset ( -- n ) 56 ;
: frame-return-offset ( -- n ) 60 ;
: flush-windows ( -- ) 0x91d02003 emit-insn ;
: load-cell ( rd base offset -- ) LD ;
: store-cell ( rd base offset -- ) ST ;
: load-cell-x ( rd base index -- ) LDR ;
: shift-right ( rd src n -- ) SRAI ;
: shift-left ( rd src n -- ) SLLI ;
: load-address ( rd -- class ) 0 SET32 rc-native-1 ;
: branch ( condition displacement -- ) f Bicc NOP ;

: multiply ( rd a b -- ) SMUL ;
:: divide ( rd a b -- )
    1 a 31 SRAI 0 1 0 48 alu-reg NOP NOP NOP rd a b SDIV ;
: shift-left-reg ( rd a b -- ) SLL ;
: shift-right-reg ( rd a b -- ) SRA ;

: product-quotient-check ( -- ) 10 0 0 40 alu-reg 12 11 31 SRAI 0 10 12 SUBcc ;
<< "resource:basis/bootstrap/assembler/sparc.factor" parse-file suffix! >> call

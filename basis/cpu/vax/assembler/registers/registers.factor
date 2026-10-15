! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.vax.assembler kernel locals make math.order ;
IN: cpu.vax.assembler.registers

CONSTANT: SP 14
CONSTANT: DS 6
CONSTANT: RS 7
CONSTANT: VM 8
CONSTANT: CTX 9
CONSTANT: temp 4
CONSTANT: temp2 5

: immediate-operand ( value -- operand )
    dup 0 63 between? [ LITERAL ] [ IMM.L ] if ;
:: MV ( DST SRC -- ) DST SRC = [ ] [ SRC R DST R MOVL ] if ;
:: LI ( DST value -- ) value immediate-operand DST R MOVL ;
:: LW ( DST BASE offset -- ) BASE offset MEM DST R MOVL ;
:: SW ( SRC BASE offset -- ) SRC R BASE offset MEM MOVL ;
:: add-offset ( DST SRC value -- )
    value immediate-operand SRC R DST R ADDL3 ;

! Relocation cursors must precede MOVL's final destination specifier.
: literal-prefix ( -- ) 0xd0 , 0 IMM.L % ;

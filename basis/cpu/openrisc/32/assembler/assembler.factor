! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.codegen.relocation compiler.constants
cpu.openrisc.32.assembler.registers endian kernel locals make math
math.bitwise math.order ;
IN: cpu.openrisc.32.assembler

ERROR: invalid-openrisc-immediate value width ;
ERROR: invalid-openrisc-register register ;

: emit-insn ( n -- ) 4 >be % ;
: R ( register -- n )
    dup int-register? [ n>> dup 0 31 between? [ ] [ invalid-openrisc-register ] if ]
    [ invalid-openrisc-register ] if ;
: F ( register -- n )
    dup fp-register? [ lo>> ] [ invalid-openrisc-register ] if ;
: fp-pair-bit ( register -- n )
    [ hi>> ] [ lo>> ] bi - 1 -
    dup 0 1 between? [ ] [ invalid-openrisc-register ] if ;
:: signed-immediate ( value width -- n )
    value width >signed value = [ value width bits ]
    [ value width invalid-openrisc-immediate ] if ;
:: unsigned-immediate ( value width -- n )
    value width bits value = [ value ]
    [ value width invalid-openrisc-immediate ] if ;

:: i-insn ( rd ra imm opcode -- )
    opcode 26 shift rd R 21 shift bitor ra R 16 shift bitor
    imm 16 signed-immediate bitor emit-insn ;
:: ui-insn ( rd ra imm opcode -- )
    opcode 26 shift rd R 21 shift bitor ra R 16 shift bitor
    imm 16 unsigned-immediate bitor emit-insn ;
:: rr-insn ( rd ra rb function -- )
    0x38 26 shift rd R 21 shift bitor ra R 16 shift bitor
    rb R 11 shift bitor function bitor emit-insn ;
:: store-insn ( src base imm opcode -- )
    imm 16 signed-immediate :> n
    opcode 26 shift base R 16 shift bitor src R 11 shift bitor
    n 0x7ff bitand bitor n 0xf800 bitand 10 shift bitor emit-insn ;

: MOVHI ( rd imm -- ) [ ZERO ] dip 0x06 ui-insn ;
: ADDI ( rd ra imm -- ) 0x27 i-insn ;
: ANDI ( rd ra imm -- ) 0x29 ui-insn ;
: ORI ( rd ra imm -- ) 0x2a ui-insn ;
: XORI ( rd ra imm -- ) 0x2b ui-insn ;
: MULI ( rd ra imm -- ) 0x2c i-insn ;
: LWZ ( rd base imm -- ) 0x21 i-insn ;
: LWS ( rd base imm -- ) 0x22 i-insn ;
: LBZ ( rd base imm -- ) 0x23 i-insn ;
: LBS ( rd base imm -- ) 0x24 i-insn ;
: LHZ ( rd base imm -- ) 0x25 i-insn ;
: LHS ( rd base imm -- ) 0x26 i-insn ;
: SW ( src base imm -- ) 0x35 store-insn ;
: SB ( src base imm -- ) 0x36 store-insn ;
: SH ( src base imm -- ) 0x37 store-insn ;
: ADD ( rd ra rb -- ) 0x000 rr-insn ;
: SUB ( rd ra rb -- ) 0x002 rr-insn ;
: AND ( rd ra rb -- ) 0x003 rr-insn ;
: OR ( rd ra rb -- ) 0x004 rr-insn ;
: XOR ( rd ra rb -- ) 0x005 rr-insn ;
: SLL ( rd ra rb -- ) 0x008 rr-insn ;
: SRL ( rd ra rb -- ) 0x048 rr-insn ;
: SRA ( rd ra rb -- ) 0x088 rr-insn ;
: MUL ( rd ra rb -- ) 0x306 rr-insn ;
: MULD ( ra rb -- ) ZERO -rot 0x307 rr-insn ;
: DIV ( rd ra rb -- ) 0x309 rr-insn ;
: DIVU ( rd ra rb -- ) 0x30a rr-insn ;
: SLLI ( rd ra n -- ) 0x00 6 shift bitor 0x2e ui-insn ;
: SRLI ( rd ra n -- ) 0x01 6 shift bitor 0x2e ui-insn ;
: SRAI ( rd ra n -- ) 0x02 6 shift bitor 0x2e ui-insn ;
: MV ( rd src -- ) dup OR ;
: NEG ( rd src -- ) [ ZERO ] dip SUB ;
: NOT ( rd src -- )
    temp1 0xffff MOVHI temp1 temp1 0xffff ORI temp1 XOR ;

: NOP ( -- ) 0x15000000 emit-insn ;
: JR ( rb -- ) R 11 shift 0x44000000 bitor emit-insn ;
: JALR ( rb -- ) R 11 shift 0x48000000 bitor emit-insn ;
: RET ( -- ) RA JR NOP ;

:: MFSPR ( rd ra imm -- )
    0x2d 26 shift rd R 21 shift bitor ra R 16 shift bitor
    imm 16 unsigned-immediate bitor emit-insn ;
:: MTSPR ( ra rb imm -- )
    imm 16 unsigned-immediate :> n
    0x30 26 shift ra R 16 shift bitor rb R 11 shift bitor
    n 0x7ff bitand bitor n 0xf800 bitand 10 shift bitor emit-insn ;

:: branch-insn ( displacement opcode -- )
    displacement 3 bitand zero? [ ] [ displacement 26 invalid-openrisc-immediate ] if
    displacement -2 shift 26 signed-immediate opcode bitor emit-insn ;
: J ( displacement -- ) 0x00000000 branch-insn ;
: JAL ( displacement -- ) 0x04000000 branch-insn ;
: BNF ( displacement -- ) 0x0c000000 branch-insn ;
: BF ( displacement -- ) 0x10000000 branch-insn ;

:: sf-insn ( ra rb function -- )
    0x39 26 shift ra R 16 shift bitor rb R 11 shift bitor function 21 shift bitor emit-insn ;
: SFEQ ( ra rb -- ) 0 sf-insn ;
: SFNE ( ra rb -- ) 1 sf-insn ;
: SFGTU ( ra rb -- ) 2 sf-insn ;
: SFGEU ( ra rb -- ) 3 sf-insn ;
: SFLTU ( ra rb -- ) 4 sf-insn ;
: SFLEU ( ra rb -- ) 5 sf-insn ;
: SFGTS ( ra rb -- ) 10 sf-insn ;
: SFGES ( ra rb -- ) 11 sf-insn ;
: SFLTS ( ra rb -- ) 12 sf-insn ;
: SFLES ( ra rb -- ) 13 sf-insn ;

:: fp3-insn ( dst lhs rhs function -- )
    0x32 26 shift dst F 21 shift bitor lhs F 16 shift bitor
    rhs F 11 shift bitor dst fp-pair-bit 10 shift bitor
    lhs fp-pair-bit 9 shift bitor rhs fp-pair-bit 8 shift bitor
    function bitor emit-insn ;
: FADD.D ( dst lhs rhs -- ) 0x10 fp3-insn ;
: FSUB.D ( dst lhs rhs -- ) 0x11 fp3-insn ;
: FMUL.D ( dst lhs rhs -- ) 0x12 fp3-insn ;
: FDIV.D ( dst lhs rhs -- ) 0x13 fp3-insn ;
:: fp2-insn ( dst src function -- )
    0x32 26 shift dst F 21 shift bitor src F 16 shift bitor
    dst fp-pair-bit 10 shift bitor src fp-pair-bit 9 shift bitor
    function bitor emit-insn ;
: ITOF.D ( dst src -- ) 0x14 fp2-insn ;
: FTOI.D ( dst src -- ) 0x15 fp2-insn ;
:: fpcmp-insn ( lhs rhs function -- )
    0x32 26 shift lhs F 16 shift bitor rhs F 11 shift bitor
    lhs fp-pair-bit 9 shift bitor rhs fp-pair-bit 8 shift bitor
    function bitor emit-insn ;
: FSEQ.D ( lhs rhs -- ) 0x18 fpcmp-insn ;
: FSNE.D ( lhs rhs -- ) 0x19 fpcmp-insn ;
: FSGT.D ( lhs rhs -- ) 0x1a fpcmp-insn ;
: FSGE.D ( lhs rhs -- ) 0x1b fpcmp-insn ;
: FSLT.D ( lhs rhs -- ) 0x1c fpcmp-insn ;
: FSLE.D ( lhs rhs -- ) 0x1d fpcmp-insn ;
: FSUEQ.D ( lhs rhs -- ) 0x38 fpcmp-insn ;
: FSUN.D ( lhs rhs -- ) 0x3e fpcmp-insn ;

:: LI32 ( rd value -- )
    rd value -16 shift 16 bits MOVHI rd rd value 16 bits ORI ;
:: LI ( rd value -- )
    value 16 >signed value = [ rd ZERO value ADDI ] [ rd value LI32 ] if ;
: load-address ( rd -- class ) 0 LI32 rc-native-0 ;

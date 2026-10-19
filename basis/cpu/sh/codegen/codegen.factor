! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.codegen.relocation cpu.sh.assembler kernel layouts locals
make math math.bitwise math.order namespaces sequences ;
IN: cpu.sh.codegen

CONSTANT: DS 8
CONSTANT: RS 9
CONSTANT: VM 10
CONSTANT: SAFEPOINT 11
CONSTANT: CTX 12
ALIAS: PIC CTX
CONSTANT: PIC-TAIL 13
CONSTANT: FP 14
CONSTANT: SP 15
CONSTANT: temp 0
CONSTANT: temp2 1

: align-code ( -- ) compiled-offset 3 bitand zero? [ ] [ NOP ] if ;
:: MV ( dst src -- ) dst src = [ ] [ src dst MOV ] if ;
! An inline pool is unreachable by fallthrough. Its four-byte alignment
! permits VM relocation and instruction-cache patching at either byte order.
:: literal ( dst value -- )
    align-code
    [ NOP ] B{ } make :> padding
    [ value emit-long ] B{ } make :> data
    padding length 2 + dst LOAD-PC.L
    padding length data length + 4 + BRA NOP
    padding % data % ;
:: LI ( dst value -- )
    value -128 127 between? [ value dst MOVI ] [ dst value literal ] if ;
: load-address ( dst -- ) 0 literal ;
:: add-offset ( dst src offset -- )
    offset -128 127 between? [ dst src MV offset dst ADDI ]
    [ dst src MV dst temp = temp2 temp ? :> scratch
      scratch offset LI scratch dst ADD ] if ;
:: address ( base offset -- reg )
    offset zero? [ base ] [ 7 base offset add-offset 7 ] if ;
:: LW ( dst base offset -- )
    offset 0 60 between? offset 3 bitand zero? and
    [ base offset dst LOAD-DISP.L ] [ base offset address dst MOV.L ] if ;
:: SW ( src base offset -- )
    offset 0 60 between? offset 3 bitand zero? and
    [ src base offset STORE-DISP.L ] [
        7 base MV
        offset -128 127 between? [ offset 7 ADDI ] [
            src temp = temp2 temp ? :> scratch
            scratch offset LI scratch 7 ADD
        ] if src 7 STORE.L
    ] if ;
:: call-literal ( value tail? -- )
    align-code
    [ NOP ] B{ } make :> padding
    [ value emit-long ] B{ } make :> data
    ! LOAD; JSR/JMP; delay; BRA; delay; padding; literal.
    padding length 6 + temp LOAD-PC.L
    temp tail? [ JMP ] [ JSR ] if NOP
    padding length data length + 4 + BRA NOP padding % data % ;
: call-literal-size ( -- n ) 5 2 * 2 + 4 + ;
: CALL ( -- ) 0 f call-literal ;
: JUMP ( -- ) 0 t call-literal ;
: RETURN ( -- ) RTS NOP ;
! SP can select a suspended frame independently of the current FP.
! Preserve R0/R1, which can contain a two-word callback result.
: linked-epilog ( -- )
    7 SP 4 LW 7 LDS-PR FP SP 0 LW SP SP 16 add-offset ;

:: binary-op ( dst src1 src2 op -- )
    dst src2 = dst src1 = not and
    [ temp2 src2 MV temp2 ] [ src2 ] if :> rhs
    dst src1 MV rhs dst op call( src dst -- ) ; inline
:: immediate-op ( dst src value op -- )
    temp2 value LI dst src temp2 op call( dst src rhs -- ) ; inline
:: sh-shift ( dst src count arithmetic? -- )
    dst temp = src temp = or
    [ dst temp2 = src temp2 = or [ 7 ] [ temp2 ] if ] [ temp ] if :> scratch
    scratch count MV dst src MV scratch dst arithmetic? [ SHAD ] [ SHLD ] if ;
:: sh-shift-immediate ( dst src count arithmetic? -- )
    src temp = temp2 temp ? :> scratch
    scratch count LI dst src scratch arithmetic? sh-shift ;

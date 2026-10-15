! Final SVR4 PowerPC32 aggregate return convention.
USING: accessors alien.c-types arrays classes.tuple
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions cpu.architecture kernel
layouts locals math math.order sequences system ;
QUALIFIED-WITH: alien.c-types c
IN: cpu.ppc.32.svr4

! Aggregates through eight bytes return as a right-justified integer value
! in r3 or r3/r4. Larger aggregates use the ordinary hidden result pointer.
M: ppc.32 return-struct-in-registers? heap-size 8 <= ;
M: ppc.32 flatten-struct-type-return
    heap-size 4 align 4 /i { int-rep f f } <repetition> record-reg-reps ;

TUPLE: ppc32-return-part size ;
C: <ppc32-return-part> ppc32-return-part

:: ppc32-return-components ( size -- offsets parts )
    size 4 mod :> head
    head zero? [
        size 4 /i <iota> [ 4 * ] map dup length f <array>
    ] [
        size 4 > [ { 0 } head suffix { f } ] [ { 0 } { } ] if
        head <ppc32-return-part> prefix
    ] if ;

M: ppc.32 struct-components nip heap-size ppc32-return-components ;

M:: ppc32-return-part load-struct-component ( src offset rep part -- dst )
    part size>> :> size
    size <iota> 0 ^^load-integer [| dst index |
        src offset index + int-rep c:uchar ^^load-memory-imm
        size index - 1 - 8 * ^^shl-imm dst swap ^^or
    ] reduce ;

M:: ppc32-return-part store-struct-component ( value src offset rep part -- )
    part size>> :> size
    size <iota> [| index |
        value size index - 1 - 8 * ^^shr-imm
        src offset index + int-rep c:uchar ##store-memory-imm,
    ] each ;

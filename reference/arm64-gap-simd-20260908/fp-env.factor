USING: accessors compiler.cfg.instructions compiler.test continuations cpu.architecture
io kernel kernel.private locals math.floats.env math.floats.env.arm.64 math.vectors.conversion
math.vectors.simd math.vectors.simd.intrinsics prettyprint sequences system ;
IN: arm64-gap-simd.fp-env
: native-conversion ( x -- y ) { float-4 } declare float-4 int-4 vconvert ;
: portable-conversion ( x rep -- y ) (simd-v>integer) ;
:: report ( x -- )
    "Input bits: " write x uint-4-cast .
    "Native flags: " write [ x native-conversion drop ] collect-fp-exceptions .
    "Portable flags: " write [ x underlying>> float-4-rep portable-conversion drop ] collect-fp-exceptions .
    "Native with invalid+inexact traps: " write
    [ { +fp-invalid-operation+ +fp-inexact+ }
      [ x native-conversion drop ] with-fp-traps "returned" print ]
    [ vm-error>exception-flags . ] recover
    "Portable with invalid+inexact traps: " write
    [ { +fp-invalid-operation+ +fp-inexact+ }
      [ x underlying>> float-4-rep portable-conversion drop ] with-fp-traps "returned" print ]
    [ vm-error>exception-flags . ] recover flush ;
"Native conversion CFG: " write
[ { float-4 } declare float-4 int-4 vconvert ] [ ##float>integer-vector? ] contains-insn? .
"Effective traps requested invalid+inexact: " write
{ +fp-invalid-operation+ +fp-inexact+ } [ fp-traps ] with-fp-traps .
float-4{ 1.5 -1.5 0.5 -0.5 } report
uint-4{ 0x7f800000 0xff800000 0x7f800000 0xff800000 } float-4-cast report
uint-4{ 0x7fc00001 0xffc00001 0x7fc00001 0xffc00001 } float-4-cast report
uint-4{ 0x7f800001 0xff800001 0x7f800001 0xff800001 } float-4-cast report
uint-4{ 0x00000001 0x80000001 0x007fffff 0x807fffff } float-4-cast report
float-4{ 2147483648 4294967808 -2147483904 -4294967808 } report
0 exit

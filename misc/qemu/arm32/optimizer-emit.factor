! Generate executable ARM32 scalar and native-ABI probe functions.
! Run with this repository as Factor's resource path and refreshed compiler
! vocabularies. optimizer-native.c consumes the emitted /tmp binaries.
USING: alien.c-types compiler.cfg.comparisons cpu.architecture cpu.arm.32
cpu.arm.32.assembler cpu.arm.32.compiler-assembler generic io.encodings.binary
io.files kernel layouts literals make namespaces ;
emit-bytecode? on have-BX? on
[ 16 M\ arm.32 %prologue execute R0 R0 R1 M\ arm.32 %add execute
  16 M\ arm.32 %epilogue execute M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-add.bin" binary set-file-contents
[ D0 D0 D1 M\ arm.32 %add-float execute M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-fadd.bin" binary set-file-contents
[ D4 S0 float-rep M\ arm.32 %copy execute
  D5 D1 double-rep M\ arm.32 %copy execute
  D6 S1 float-rep M\ arm.32 %copy execute
  D4 D4 M\ arm.32 %single>double-float execute
  D6 D6 M\ arm.32 %single>double-float execute
  D0 D4 D5 M\ arm.32 %add-float execute
  D0 D0 D6 M\ arm.32 %add-float execute
  M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-mixed.bin" binary set-file-contents
[ R0 R0 0 int-rep char M\ arm.32 %load-memory-imm execute
  M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-schar.bin" binary set-file-contents
[ R0 R0 short M\ arm.32 %convert-integer execute
  M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-short.bin" binary set-file-contents
[ D0 D1 D2 M\ arm.32 %add-float execute M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-hfa-arg.bin" binary set-file-contents
[ D4 S0 float-rep M\ arm.32 %copy execute D5 S1 float-rep M\ arm.32 %copy execute
  D4 D4 M\ arm.32 %single>double-float execute D5 D5 M\ arm.32 %single>double-float execute
  D6 D4 D5 M\ arm.32 %add-float execute D7 D6 M\ arm.32 %double>single-float execute
  D4 D4 M\ arm.32 %double>single-float execute
  S0 D7 float-rep M\ arm.32 %copy execute S1 D4 float-rep M\ arm.32 %copy execute
  M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-hfa-ret.bin" binary set-file-contents
[ D0 D1 VCMP PC VMRS R0 0 MOV cc< float-cc R0 1 MOV M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-fplt.bin" binary set-file-contents
[ D0 D1 VCMP PC VMRS R0 0 MOV cc/<= float-cc R0 1 MOV M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-fpnotle.bin" binary set-file-contents
[ ${ R4 LR } PUSH R0 R0 M\ arm.32 %bit-count execute ${ R4 LR } POP M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-popcount.bin" binary set-file-contents
[ ${ R4 LR } PUSH VPUSH-D8-D15 D0 D0 D1 M\ arm.32 %min-float execute VPOP-D8-D15 ${ R4 LR } POP M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-fmin.bin" binary set-file-contents
4 \ cell [
    [ ${ R4 R8 R12 LR } PUSH R8 R0 MOV
      R0 M\ arm.32 %callback-stack execute
      ${ R4 R8 R12 LR } POP M\ arm.32 %return execute ] B{ } make
    "/tmp/arm32-backend-cb-stack.bin" binary set-file-contents
    [ ${ R4 R8 R12 LR } PUSH R8 R0 MOV
      R0 int-rep 0 4 %load-stack-param
      ${ R4 R8 R12 LR } POP M\ arm.32 %return execute ] B{ } make
    "/tmp/arm32-backend-cb-int.bin" binary set-file-contents
    [ ${ R4 R8 R12 LR } PUSH R8 R0 MOV
      D0 double-rep 8 8 %load-stack-param
      ${ R4 R8 R12 LR } POP M\ arm.32 %return execute ] B{ } make
    "/tmp/arm32-backend-cb-double.bin" binary set-file-contents
] with-variable
[ D0 R2 R3 VMOV-CORE-TO-DOUBLE R0 R1 D0 VMOV-DOUBLE-TO-CORE M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-varargs.bin" binary set-file-contents

! AAPCS core composites can straddle the register/stack boundary.
[ R0 R0 R1 M\ arm.32 %add execute R0 R0 R2 M\ arm.32 %add execute
  R0 R0 R3 M\ arm.32 %add execute R12 SP 0 <+> LDR
  R0 R0 R12 M\ arm.32 %add execute M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-struct-split.bin" binary set-file-contents
[ R0 R0 R2 M\ arm.32 %add execute R12 SP 0 <+> LDR
  R0 R0 R12 M\ arm.32 %add execute M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-struct-wide.bin" binary set-file-contents

[ R0 R0 0 M\ arm.32 %shr-imm execute M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-shr0.bin" binary set-file-contents
[ R0 R0 0 M\ arm.32 %sar-imm execute M\ arm.32 %return execute ] B{ } make
"/tmp/arm32-backend-sar0.bin" binary set-file-contents

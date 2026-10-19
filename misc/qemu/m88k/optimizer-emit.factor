! Uses the optimizing backend hooks, not handwritten native instruction bytes.
USING: arrays alien.c-types byte-arrays command-line compiler.cfg.instructions compiler.cfg.comparisons cpu.architecture
cpu.m88k cpu.m88k.assembler cpu.m88k.assembler.registers
io.encodings.binary io.files io.pathnames kernel locals make namespaces sequences system ;
IN: cpu.m88k.optimizer-emit
: save-code ( bytes name -- ) command-line get first prepend-path binary set-file-contents ;
m88k.32 \ cpu [
    [ R2 R2 R3 %add RET ] B{ } make "m88k-add.bin" save-code
    [ R2 R2 R3 %sub RET ] B{ } make "m88k-sub.bin" save-code
    [ R2 R2 -42 %add-imm RET ] B{ } make "m88k-offset.bin" save-code
    [ R2 -1 %load-immediate RET ] B{ } make "m88k-negative.bin" save-code
    [ 32 %prologue R2 42 %load-immediate 32 %epilogue RET ] B{ } make "m88k-frame.bin" save-code
    [ 32 %prologue R2 SP 16 ST R2 0 %load-immediate R2 SP 16 LD
      32 %epilogue RET ] B{ } make "m88k-spill.bin" save-code
    [ R2 R2 R4 %add-float RET ] B{ } make "m88k-double.bin" save-code
    [ R2 R2 R3 %mul RET ] B{ } make "m88k-mul.bin" save-code
    [ R2 R2 R3 %shl RET ] B{ } make "m88k-shl.bin" save-code
    [ R2 R2 R3 %shr RET ] B{ } make "m88k-shr.bin" save-code
    [ R2 R2 R3 %sar RET ] B{ } make "m88k-sar.bin" save-code
    [ R2 R2 R3 cc< compare-bit RET ] B{ } make "m88k-lt.bin" save-code
    [ R2 R2 1 int-rep uint %load-memory-imm RET ] B{ } make "m88k-unaligned-load.bin" save-code
    [ R2 R2 1 int-rep short %load-memory-imm RET ] B{ } make "m88k-unaligned-half.bin" save-code
    [ R3 R2 1 int-rep uint %store-memory-imm R2 R3 int-rep %copy RET ] B{ } make "m88k-unaligned-store.bin" save-code
    [ R2 R2 %integer>float RET ] B{ } make "m88k-int-double.bin" save-code
    [ R2 R2 %float>integer RET ] B{ } make "m88k-double-int.bin" save-code
    { cc< cc<= cc= cc> cc>= cc<> cc<>= cc/< cc/<= cc/= cc/> cc/>= cc/<> cc/<>= }
    [| cc | [ R2 R2 R4 cc float-bit RET ] B{ } make ] map concat
    "m88k-float-predicates.bin" save-code
    [ 32 %prologue
      R2 1 %load-immediate R3 2 %load-immediate R4 3 %load-immediate R5 4 %load-immediate
      R6 5 %load-immediate R7 6 %load-immediate R8 7 %load-immediate R9 8 %load-immediate
      R10 9 %load-immediate R12 10 %load-immediate
      f { } R10 int-rep 0 4 4array R12 int-rep 4 4 4array 2array
      { } { } 0 8 [ NATIVE-STACK SP 16 add-offset TRAMPOLINE2 JSR ] %alien-assembly
      32 %epilogue RET ] B{ } make "m88k-native-stack-call.bin" save-code
    [ R2 R2 R3 mul-overflow RET ] B{ } make "m88k-mul-low.bin" save-code
    [ R2 R2 R3 mul-overflow R2 temp2 int-rep %copy RET ] B{ } make "m88k-mul-overflow.bin" save-code
    [ R2 R2 R3 add-overflow R2 temp2 int-rep %copy RET ] B{ } make "m88k-add-overflow.bin" save-code
    [ R2 R2 R3 sub-overflow R2 temp2 int-rep %copy RET ] B{ } make "m88k-sub-overflow.bin" save-code
] with-variable

! Run with a host image after loading the target system/cpu.hppa sources.
USING: byte-arrays command-line compiler.cfg.comparisons cpu.architecture
cpu.hppa cpu.hppa.assembler cpu.hppa.assembler.registers io.encodings.binary
io.files io.pathnames kernel layouts locals make namespaces sequences system ;
IN: cpu.hppa.optimizer-emit
4 \ cell set
: save-code ( bytes name -- ) command-line get first prepend-path binary set-file-contents ;
hppa.32 \ cpu [
    [ RETURN arg1 arg2 %add RET ] B{ } make "hppa-add.bin" save-code
    [ RETURN arg1 arg2 %sub RET ] B{ } make "hppa-sub.bin" save-code
    [ RETURN arg1 arg2 cc< compare-bit RET ] B{ } make "hppa-lt.bin" save-code
    [ arg1 arg1 arg2 cc< compare-bit RETURN arg1 COPY RET ] B{ } make "hppa-alias.bin" save-code
    [ RETURN arg1 arg2 %shl RET ] B{ } make "hppa-shl.bin" save-code
    [ RETURN arg1 arg2 %shr RET ] B{ } make "hppa-shr.bin" save-code
    [ RETURN arg1 arg2 %sar RET ] B{ } make "hppa-sar.bin" save-code
    [ 20000 %prologue RETURN 42 %load-immediate 20000 %epilogue RET ] B{ } make "hppa-frame.bin" save-code
    [ F8 arg1 %integer>float RETURN F8 %float>integer RET ] B{ } make "hppa-convert.bin" save-code
    [ RETURN arg1 arg2 %mul RET ] B{ } make "hppa-mul.bin" save-code
    { cc< cc<= cc> cc>= cc= cc<> cc<>= cc/< cc/<= cc/> cc/>= cc/= cc/<> cc/<>= }
    [| cc | [ RETURN F5 F7 cc float-bit RET ] B{ } make ] map concat
    "hppa-float-cmp.bin" save-code
    [ RETURN arg1 arg2 add-overflow RETURN temp2 ZERO cc/= compare-bit RET ] B{ } make "hppa-add-overflow.bin" save-code
    [ RETURN arg1 arg2 sub-overflow RETURN temp2 ZERO cc/= compare-bit RET ] B{ } make "hppa-sub-overflow.bin" save-code
    [ IP1 NATIVE-SP -24 STW temp1 NATIVE-SP -20 STW
      RETURN arg1 arg2 mul-overflow RETURN temp2 ZERO cc/= compare-bit
      IP1 NATIVE-SP -24 LDW temp1 NATIVE-SP -20 LDW RET ] B{ } make "hppa-mul-overflow.bin" save-code
] with-variable

USING: alien.c-types ;

hppa.32 \ cpu [
 [ IP1 NATIVE-SP -24 STW temp1 NATIVE-SP -20 STW
 arg2 arg1 1 int-rep uint base-type %store-memory-imm
 RETURN arg1 1 int-rep uint base-type %load-memory-imm
 IP1 NATIVE-SP -24 LDW temp1 NATIVE-SP -20 LDW RET ] B{ } make "hppa-memory-word.bin" save-code
 [ IP1 NATIVE-SP -24 STW temp1 NATIVE-SP -20 STW
 RETURN arg1 1 int-rep alien.c-types:char base-type %load-memory-imm
 IP1 NATIVE-SP -24 LDW temp1 NATIVE-SP -20 LDW RET ] B{ } make "hppa-memory-byte.bin" save-code
 [ IP1 NATIVE-SP -24 STW temp1 NATIVE-SP -20 STW
 RETURN arg1 1 int-rep short base-type %load-memory-imm
 IP1 NATIVE-SP -24 LDW temp1 NATIVE-SP -20 LDW RET ] B{ } make "hppa-memory-half.bin" save-code
 [ IP1 NATIVE-SP -24 STW temp1 NATIVE-SP -20 STW
 F7 arg1 1 double-rep f %store-memory-imm F4 arg1 1 double-rep f %load-memory-imm
 IP1 NATIVE-SP -24 LDW temp1 NATIVE-SP -20 LDW RET ] B{ } make "hppa-memory-double.bin" save-code
 [ F4 1.25 %load-double RET ] B{ } make "hppa-constant-double.bin" save-code
 [ F4 1.25 %load-float RET ] B{ } make "hppa-constant-float.bin" save-code
] with-variable

USING: arrays ;
hppa.32 \ cpu [
    [ 16 %prologue
      arg1 f arg2 int-rep arg1 3array arg3 int-rep arg2 3array 2array
      { } RETURN int-rep RETURN 3array 1array { } 0 8 f %alien-indirect
      16 %epilogue RET ] B{ } make "hppa-indirect.bin" save-code
] with-variable

USING: accessors compiler.codegen.labels compiler.codegen.relocation endian vectors math ;
:: save-labeled ( quot name -- )
    init-relocation V{ } clone label-table set
    quot B{ } make name save-code
    label-table get [ [ offset>> 8 - 4 >be ] [ compute-target 4 >be ] bi append ] map concat
    name ".labels" append save-code ; inline
hppa.32 \ cpu [
    [ 16 %prologue RETURN arg1 temp2 %box-alien 16 %epilogue RET ] "hppa-box-alien.bin" save-labeled
    [ 16 %prologue RETURN arg2 arg1 temp2 f %box-displaced-alien 16 %epilogue RET ] "hppa-box-displaced.bin" save-labeled
    [ 16 %prologue RETURN arg1 %unbox-any-c-ptr 16 %epilogue RET ] "hppa-unbox-pointer.bin" save-labeled
] with-variable

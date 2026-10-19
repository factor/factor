! Canonical-register NaN execution and precision adapters, emitted by Factor.
USING: accessors alien.c-types byte-arrays command-line compiler.cfg.comparisons
compiler.codegen.labels compiler.codegen.relocation cpu.architecture cpu.hppa
cpu.hppa.assembler cpu.hppa.assembler.registers endian io.encodings.binary
io.files io.pathnames kernel layouts locals make math namespaces sequences
system vectors ;
IN: cpu.hppa.nan-emit
:: save-code ( bytes name -- )
    bytes command-line get first name append-path binary set-file-contents ;
:: emit-nan ( quot name -- )
    init-relocation V{ } clone label-table set
    [ temp1 NATIVE-SP -24 STW IP1 NATIVE-SP -28 STW
      quot call( -- ) IP1 NATIVE-SP -28 LDW temp1 NATIVE-SP -24 LDW RET ] B{ } make
    name save-code
    label-table get [ [ offset>> 8 - 4 >be ] [ compute-target 4 >be ] bi append ] map concat
    name ".labels" append save-code ; inline
hppa.32 \ cpu [ 4 \ cell [
    [ F8 arg1 0 FLDD F9 arg2 0 FLDD F10 F8 F9 %add-float F10 arg3 0 FSTD ] "add.bin" emit-nan
    [ F8 arg1 0 FLDD F9 arg2 0 FLDD F10 F8 F9 %sub-float F10 arg3 0 FSTD ] "sub.bin" emit-nan
    [ F8 arg1 0 FLDD F9 arg2 0 FLDD F10 F8 F9 %mul-float F10 arg3 0 FSTD ] "mul.bin" emit-nan
    [ F8 arg1 0 FLDD F9 arg2 0 FLDD F10 F8 F9 %div-float F10 arg3 0 FSTD ] "div.bin" emit-nan
    [ F8 arg1 0 FLDD F9 arg2 0 FLDD RETURN F8 F9 cc< t float-bit-mode ] "quiet.bin" emit-nan
    [ F8 arg1 0 FLDD F9 arg2 0 FLDD RETURN F8 F9 cc< f float-bit-mode ] "ordered.bin" emit-nan
    [ F8 arg1 0 FLDW F9 F8 %single>double-float F9 arg2 0 FSTD ] "widen.bin" emit-nan
    [ F8 arg1 0 FLDD F9 F8 %double>single-float F9 arg2 0 FSTW ] "narrow.bin" emit-nan
    [ F8 arg1 0 double-rep double base-type %load-memory-imm F8 arg2 0 FSTD ] "foreign-load.bin" emit-nan
    [ F8 arg1 0 FLDD F8 arg2 0 double-rep double base-type %store-memory-imm ] "foreign-store.bin" emit-nan
    [ F8 arg1 0 FLDD F8 double-rep F5 store-call-input F5 NATIVE-SP -40 double-rep load-rep F5 arg2 0 FSTD ] "home.bin" emit-nan
    [ F8 arg1 0 FLDD F8 NATIVE-SP -56 double-rep store-rep F9 double-rep F5 load-callback-input F9 arg2 0 FSTD ] "callback-input.bin" emit-nan
] with-variable ] with-variable

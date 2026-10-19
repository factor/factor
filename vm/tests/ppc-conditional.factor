! Run with the matching complete resource tree; outputs are BE instruction bytes.
USING: compiler compiler.units parser system namespaces vocabs.loader ;
<< disable-optimizer "resource:core/system/system.factor" run-file
"resource:basis/compiler/constants/constants.factor" run-file
"cpu.architecture" reload "compiler.cfg.builder.alien.params" reload "compiler.cfg.builder.alien.boxing" reload >>
USE: cpu.ppc
<< ppc.64 \ cpu set-global "cpu.ppc" reload >>
USING: accessors compiler.codegen.labels compiler.codegen.relocation cpu.ppc.assembler kernel make sequences tools.test vectors ;
{ t } [ init-relocation V{ } clone label-table set [ 12 2 <label> BC ] B{ } make [ 12 2 8 cpu.ppc.assembler:BC 8 cpu.ppc.assembler:B 0 cpu.ppc.assembler:B ] B{ } make = ] unit-test
{ t } [ label-table get first class>> rc-relative-ppc-3-pc = ] unit-test
{ t } [ init-relocation V{ } clone label-table set [ 16 0 <label> BC ] B{ } make [ 16 0 8 cpu.ppc.assembler:BC 8 cpu.ppc.assembler:B 0 cpu.ppc.assembler:B ] B{ } make = ] unit-test
USING: io.files io.encodings.binary ;
init-relocation V{ } clone label-table set
[ 12 2 <label> BC ] B{ } make
"ppc-conditional-cr.bin" binary set-file-contents
init-relocation V{ } clone label-table set
[ 16 0 <label> BC ] B{ } make
"ppc-conditional-ctr.bin" binary set-file-contents
USING: math ;
IN: ppc.conditional.proof
: predicate-bytes ( bo bi -- bytes )
    init-relocation V{ } clone label-table set
    [ <label> BC ] B{ } make ;
[ { 4 12 } [ 32 <iota> [ over swap predicate-bytes % ] each drop ] each ] B{ } make
"ppc-conditional-predicates.bin" binary set-file-contents

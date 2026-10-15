USING: compiler.units compiler.errors io.files namespaces parser prettyprint ;
"core/system/system.factor" run-file
"basis/cpu/architecture/architecture.factor" run-file
"basis/compiler/cfg/builder/alien/params/params.factor" run-file
"basis/compiler/cfg/builder/alien/boxing/boxing.factor" run-file
"basis/compiler/cfg/builder/alien/alien.factor" run-file
"basis/cpu/arm/32/32.factor" run-file
USING: byte-arrays compiler.cfg compiler.cfg.instructions compiler.cfg.stack-frame cpu.architecture cpu.arm.32 cpu.arm.32.assembler cpu.arm.32.assembler.registers compiler.codegen.relocation cpu.arm.32.compiler-assembler io.encodings.binary kernel literals make ;
IN: arm32-stackcall-probe
emit-bytecode? on have-BLX? on have-BX? on
: prefix ( -- ) ${ R4 R8 R10 FP IP LR } PUSH SP SP 32 SUB R8 SP 24 ADD LR 5 LI LR SP 0 <+> STR LR 6 LI LR SP 4 <+> STR ;
: suffix ( -- ) SP SP 32 ADD ${ R4 R8 R10 FP IP LR } POP LR BX ;
arm.32 \ cpu [
 init-relocation [ prefix 24 { "sixarg" } f f %c-invoke-tramp2 suffix ] B{ } make "/tmp/arm32-backend-direct.bin" binary set-file-contents
 relocation-table get >byte-array "/tmp/arm32-backend-direct.rel" binary set-file-contents
 init-relocation
 T{ cfg { stack-frame T{ stack-frame { spill-area-base 0 } } } } \ cfg [
 [ prefix R0 SP 24 <+> STR R0 1 LI R1 2 LI R2 3 LI R3 4 LI
   T{ spill-slot { n 24 } } f { } { } { } { } 0 24 f
   %alien-indirect suffix ] B{ } make
 ] with-variable "/tmp/arm32-backend-indirect.bin" binary set-file-contents
 relocation-table get >byte-array "/tmp/arm32-backend-indirect.rel" binary set-file-contents
] with-variable
compiler-errors get-global .

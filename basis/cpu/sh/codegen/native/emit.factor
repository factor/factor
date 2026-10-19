USING: parser ;
<< "resource:core/system/system.factor" run-file >>
USING: cpu.architecture cpu.sh cpu.sh.assembler cpu.sh.codegen compiler.codegen.relocation io.files io.encodings.binary kernel layouts locals make math namespaces system ;
IN: cpu.sh.codegen.native
[ init-relocation 0 0x89abcdef LI RETURN ] B{ } make "artifacts/literal.bin" binary set-file-contents
[ init-relocation 2 11 LI 3 7 LI 3 2 3 [ SUB ] binary-op 0 3 MV RETURN ] B{ } make "artifacts/alias-sub.bin" binary set-file-contents
[ init-relocation 2 0x80000000 LI 0 -31 LI 1 2 0 f sh-shift 0 1 MV RETURN ] B{ } make "artifacts/shift.bin" binary set-file-contents
[ init-relocation SP STS.L-PR CALL SP LDS.L-PR RETURN ] B{ } make "artifacts/call.bin" binary set-file-contents
[ init-relocation 1 STS-FPSCR 0 0x80000 LI 0 LDS-FPSCR
  sh4.32 \ cpu [ 6 4 6 %sub-float ] with-variable
  0 6 FMV 1 LDS-FPSCR RETURN ] B{ } make "artifacts/float.bin" binary set-file-contents
[ init-relocation 1 STS-FPSCR 0 0x80000 LI 0 LDS-FPSCR
  0 4 -8 FLD 1 LDS-FPSCR RETURN ] B{ } make "artifacts/float-load.bin" binary set-file-contents
[ init-relocation 6 4 5 multiply-t 0 MOVT RETURN ] B{ } make "artifacts/multiply-overflow.bin" binary set-file-contents
:: backward-loop-code ( -- )
    init-relocation 0 0 LI 2 3 LI compiled-offset :> loop-start
    1 0 ADDI 2 DT loop-start compiled-offset - BF RETURN ;
[ backward-loop-code ] B{ } make "artifacts/backward-loop.bin" binary set-file-contents
[ init-relocation linked-epilog RETURN ] B{ } make "artifacts/linked-epilog.bin" binary set-file-contents
[ init-relocation 0 0x10e00 LI 0 0 -4 t sh-shift-immediate RETURN ] B{ } make "artifacts/shift-source.bin" binary set-file-contents
[ init-relocation 1 48 LI 0 -4 LI 2 1 0 t sh-shift 0 2 MV RETURN ] B{ } make "artifacts/shift-scratch.bin" binary set-file-contents
[ init-relocation 4 \ cell [ sh4.32 \ cpu [ 4 4 7 2 3 %write-barrier-imm ] with-variable ] with-variable RETURN ] B{ } make "artifacts/write-barrier.bin" binary set-file-contents
0 exit

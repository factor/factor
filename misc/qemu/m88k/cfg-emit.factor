! Exercises real CFG liveness, register allocation, frame building and codegen.
USING: command-line io.pathnames accessors arrays endian compiler.cfg compiler.cfg.build-stack-frame
compiler.cfg.instructions compiler.cfg.linear-scan compiler.cfg.registers compiler.cfg.ssa.destruction
compiler.cfg.utilities compiler.codegen compiler.codegen.relocation compiler.test cpu.m88k
cpu.m88k.optimizer-emit io.encodings.utf8 io.files kernel locals make math math.parser namespaces sequences splitting system vectors ;
IN: cpu.m88k.cfg-emit
:: pressure-insns ( -- insns )
    [
        T{ ##prologue } clone ,
        12 [| i | ##load-integer new i >>dst i 1 + >>val , ] each-integer
        11 [| i | ##add new i 12 + >>dst
            i zero? 0 i 11 + ? >>src1 i 1 + >>src2 , ] each-integer
        T{ ##replace f 22 D: 0 } clone ,
        T{ ##epilogue } clone , T{ ##return } clone ,
    ] V{ } make ;
:: float-pressure-insns ( -- insns )
    [
        T{ ##prologue } clone ,
        6 [| i | ##load-double new i >>dst i 1 + >float >>val , ] each-integer
        5 [| i | ##add-float new i 6 + >>dst
            i zero? 0 i 5 + ? >>src1 i 1 + >>src2 , ] each-integer
        T{ ##float>integer f 11 10 } clone ,
        T{ ##replace f 11 D: 0 } clone ,
        T{ ##epilogue } clone , T{ ##return } clone ,
    ] V{ } make ;
: allocate-code ( insns -- code )
    insns>cfg dup cfg set dup fake-representations dup destruct-ssa
    dup linear-scan dup build-stack-frame
    dup stack-frame>> spill-area-size>> zero?
    [ "m88k pressure probe did not spill" throw ] when generate ;
:: emit-pressure ( -- )
    big-endian relocation-byte-order set
    init-cfg-test pressure-insns allocate-code 4 swap nth "m88k-cfg-pressure.bin" save-code
    init-cfg-test float-pressure-insns allocate-code :> code
    code 4 swap nth "m88k-cfg-float.bin" save-code
    code third "m88k-cfg-float-relocations.bin" save-code
    code second [ number>string ] map "," join
    "m88k-cfg-float-literals.txt" command-line get first prepend-path utf8 set-file-contents
;
m88k.32 \ cpu [ emit-pressure ] with-variable

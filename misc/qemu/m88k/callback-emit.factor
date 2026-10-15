! A real backend callback body for the native transition/GC audit.
USING: arrays byte-arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.stack-frame compiler.codegen.gc-maps compiler.codegen.relocation cpu.architecture
cpu.m88k cpu.m88k.assembler cpu.m88k.assembler.registers
cpu.m88k.optimizer-emit endian kernel layouts locals make math namespaces
sequences system vectors ;
IN: cpu.m88k.callback-emit
4 \ cell set
:: emit-callback ( -- )
    init-relocation big-endian relocation-byte-order set
    V{ } clone gc-maps set V{ } clone return-addresses set
    [
        80 %prologue
        8 <iota> [| i | i 4 * spill-slot boa int-rep
            i 2 + int-register boa 3array ] map
        2 <iota> [| i | i 4 * 32 + spill-slot boa int-rep i 4 * 4 4array ] map
        %callback-inputs
        R4 0 %load-immediate
        10 <iota> [| i |
            R2 i 4 * spill-slot boa int-rep %copy
            R3 i 1 + %load-immediate R2 R2 R3 %mul R4 R4 R2 %add
        ] each
        40 spill-slot boa R4 int-rep %copy
        R4 0x10000 %load-immediate 44 spill-slot boa R4 tagged-rep %copy
        R4 0x1000c %load-immediate 48 spill-slot boa R4 int-rep %copy
        "callback_gc" f T{ gc-map
            { gc-roots { T{ spill-slot { n 44 } } } }
            { derived-roots { { T{ spill-slot { n 48 } } T{ spill-slot { n 44 } } } } }
        } %c-invoke
        40 spill-slot boa int-rep R2 3array 1array %callback-outputs
        80 %epilogue RET
    ] B{ } make "m88k-callback-body.bin" save-code
    relocation-table get "m88k-callback-body-relocations.bin" save-code
    serialize-gc-maps "m88k-callback-map.bin" save-code ;
m88k.32 \ cpu [
    T{ cfg { stack-frame T{ stack-frame { spill-area-base 0 } } } } cfg
    [ emit-callback ] with-variable
] with-variable

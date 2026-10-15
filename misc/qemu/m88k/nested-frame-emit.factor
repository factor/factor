! Variable-size caller/callee frame and real callsite GC metadata audit.
USING: byte-arrays compiler.cfg compiler.cfg.instructions compiler.cfg.stack-frame
compiler.codegen.gc-maps compiler.codegen.relocation cpu.architecture cpu.m88k
cpu.m88k.assembler cpu.m88k.assembler.registers cpu.m88k.optimizer-emit
endian kernel locals make math.parser namespaces sequences system vectors ;
IN: cpu.m88k.nested-frame-emit
m88k.32 \ cpu [
    T{ cfg { stack-frame T{ stack-frame { spill-area-base 0 } } } } cfg [
        init-relocation big-endian relocation-byte-order set
        V{ } clone gc-maps set V{ } clone return-addresses set
        [
            64 %prologue
            0 spill-slot boa R2 tagged-rep %copy
            4 spill-slot boa R3 int-rep %copy
            IP 0 LI32 IP JSR
            T{ gc-map
                { gc-roots { T{ spill-slot { n 0 } } } }
                { derived-roots { { T{ spill-slot { n 4 } } T{ spill-slot { n 0 } } } } }
            } gc-map-here
            R2 0 spill-slot boa tagged-rep %copy
            R3 4 spill-slot boa int-rep %copy
            64 %epilogue RET
        ] B{ } make "m88k-nested-caller.bin" save-code
        serialize-gc-maps "m88k-nested-map.bin" save-code
        init-relocation
        [
            96 %prologue R4 0xdeadbeef %load-immediate
            0 spill-slot boa R4 int-rep %copy
            "nested_observer" f f %c-invoke
            96 %epilogue RET
        ] B{ } make "m88k-nested-callee.bin" save-code
        { 64 128 } [| size |
            init-relocation
            [ size %prologue
              0 spill-slot boa R2 tagged-rep %copy
              4 spill-slot boa R3 int-rep %copy
              IP 0 LI32 IP JSR
              R2 0 spill-slot boa tagged-rep %copy
              R3 4 spill-slot boa int-rep %copy
              size %epilogue RET
            ] B{ } make
            "m88k-nested-caller" size number>string append ".bin" append save-code
        ] each
        { 64 96 } [| size |
            init-relocation
            [ size %prologue R4 0xdeadbeef %load-immediate
              0 spill-slot boa R4 int-rep %copy
              "nested_observer" f f %c-invoke size %epilogue RET
            ] B{ } make
            "m88k-nested-callee" size number>string append ".bin" append save-code
        ] each
    ] with-variable
] with-variable

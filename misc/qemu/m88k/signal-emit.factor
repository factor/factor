! Emits the resume transfer and actual safepoint bitmap for the native audit.
USING: accessors byte-arrays compiler.cfg compiler.cfg.instructions compiler.cfg.stack-frame
compiler.codegen.gc-maps compiler.codegen.relocation cpu.architecture
cpu.m88k cpu.m88k.assembler cpu.m88k.assembler.registers
cpu.m88k.optimizer-emit endian kernel make namespaces sequences system vectors ;
IN: cpu.m88k.signal-emit
m88k.32 \ cpu [
    [ IP 0 LI32 IP JMP.N IP SP 8 LD R2 ZERO IP OR RET ] B{ } make
    "m88k-signal-resume.bin" save-code
    T{ cfg { stack-frame T{ stack-frame { spill-area-base 0 } } } } cfg [
        V{ } clone gc-maps set V{ 0 } clone return-addresses set
        T{ gc-map
            { gc-roots { T{ spill-slot { n 0 } } } }
            { derived-roots { { T{ spill-slot { n 4 } } T{ spill-slot { n 0 } } } } }
        } safepoint-gc-map gc-maps get push
        big-endian relocation-byte-order set serialize-gc-maps
        "m88k-signal-map.bin" save-code
    ] with-variable
] with-variable

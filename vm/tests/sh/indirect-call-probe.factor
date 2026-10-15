! Emit the actual indirect hook with a spilled callee and both call gates.
USING: accessors arrays compiler.cfg compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stack-frame
compiler.codegen.relocation cpu.architecture cpu.sh cpu.sh.assembler cpu.sh.codegen
io.encodings.binary io.files kernel make namespaces sequences system ;
IN: sh.indirect.native.probe
sh4.32 \ cpu set
T{ cfg { stack-frame T{ stack-frame { spill-area-base 32 } } } } cfg set
: begin-probe ( -- )
    SP SP -64 add-offset FP SP 56 SW temp STS-PR temp SP 60 SW
    4 SP 48 SW CTX 5 MV
    4 1 LI 5 2 LI 6 3 LI 7 4 LI
    temp 5 LI temp SP 0 SW temp 6 LI temp SP 4 SW ;
: end-probe ( -- )
    7 SP 60 LW 7 LDS-PR FP SP 56 LW SP SP 64 add-offset RETURN ;
: emit-probe ( size -- bytes relocs )
    init-relocation [ begin-probe
      [ 16 <spill-slot> f { } { } { } { } 0 ] dip f
      M\ sh %alien-indirect execute( src varargs? reg-inputs stack-inputs
          reg-outputs dead-outputs cleanup stack-size gc-map -- )
      end-probe ] B{ } make relocation-table get ;
32 emit-probe "indirect-stack.reloc" binary set-file-contents
"indirect-stack.bin" binary set-file-contents
0 emit-probe "indirect-register.reloc" binary set-file-contents
"indirect-register.bin" binary set-file-contents

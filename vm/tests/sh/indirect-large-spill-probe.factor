! Exercise a spilled callee whose address requires the large-offset path.
USING: accessors arrays compiler.cfg compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stack-frame
compiler.codegen.relocation cpu.architecture cpu.sh cpu.sh.assembler cpu.sh.codegen
io.encodings.binary io.files kernel make namespaces sequences system ;
IN: sh.indirect.large.native.probe
sh4.32 \ cpu set
T{ cfg { stack-frame T{ stack-frame { spill-area-base 32 } } } } cfg set
: begin-probe ( -- )
    SP SP -128 add-offset FP SP 120 SW temp STS-PR temp SP 124 SW
    4 SP 100 SW CTX 5 MV
    4 1 LI 5 2 LI 6 3 LI 7 4 LI ;
: end-probe ( -- )
    7 SP 124 LW 7 LDS-PR FP SP 120 LW
    SP SP 64 add-offset SP SP 64 add-offset RETURN ;
: emit-probe ( -- bytes relocs )
    init-relocation [ begin-probe
      68 <spill-slot> f { } { } { } { } 0 0 f
      M\ sh %alien-indirect execute( src varargs? reg-inputs stack-inputs
          reg-outputs dead-outputs cleanup stack-size gc-map -- )
      end-probe ] B{ } make relocation-table get ;
emit-probe "indirect-large.reloc" binary set-file-contents
"indirect-large.bin" binary set-file-contents

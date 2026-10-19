USING: accessors compiler.cfg compiler.cfg.instructions compiler.cfg.stack-frame cpu.architecture cpu.sh cpu.sh.assembler kernel namespaces sh.nan-probe system ;
f f <basic-block> <cfg> T{ stack-frame { spill-area-base 0 } } >>stack-frame cfg set
"spill-double" [ 0 0 <spill-slot> double-rep sh-fp-source RETURN ] emit-probe
"spill-float" [ 2 0 <spill-slot> float-rep sh-fp-source 2 0 FMOV RETURN ] emit-probe

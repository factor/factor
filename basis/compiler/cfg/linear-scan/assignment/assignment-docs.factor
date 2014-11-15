USING: compiler.cfg.instructions help.markup help.syntax ;
IN: compiler.cfg.linear-scan.assignment

HELP: assign-registers-in-insn
{ $values { "insn" insn } }
{ $description "Assigns physical registers and spill slots for the virtual registers used by the instruction." } ;

HELP: assign-gc-roots
{ $values { "gc-map" gc-map } }
{ $description "Assigns spill slots for all gc roots in a gc map." }
{ $see-also spill-slot } ;

HELP: vreg>reg
{ $values { "vreg" "virtaul register" } { "reg" "register" } }
{ $description "If a live vreg is not in the pending set, then it must have been spilled." } ;

ARTICLE: "compiler.cfg.linear-scan.assignment" "Assigning registers to live intervals"
"The " { $vocab-link "compiler.cfg.linear-scan.assignment" } " assigns registers to live intervals." ;

ABOUT: "compiler.cfg.linear-scan.assignment"

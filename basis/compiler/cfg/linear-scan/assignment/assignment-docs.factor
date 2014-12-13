USING: assocs compiler.cfg compiler.cfg.instructions heaps help.markup
help.syntax math ;
IN: compiler.cfg.linear-scan.assignment

HELP: machine-live-ins
{ $var-description "Mapping from basic blocks to values which are live at the start on all incoming CFG edges." } ;

HELP: machine-live-outs
{ $var-description "Mapping from " { $link basic-block } " to an " { $link assoc } " of pairs which are the values that are live at the end. The keys of the pairs are virtual registers and the values are either real registers or spill slots." } ;

HELP: unhandled-intervals
{ $var-description { $link min-heap } " of live intervals which still need a register allocation." } ;

HELP: assign-registers-in-insn
{ $values { "insn" insn } }
{ $description "Assigns physical registers and spill slots for the virtual registers used by the instruction." } ;

HELP: assign-gc-roots
{ $values { "gc-map" gc-map } }
{ $description "Assigns spill slots for all gc roots in a gc map." } ;

HELP: assign-derived-roots
{ $values { "gc-map" gc-map } }
{ $description "Assigns pairs of spill slots for all derived roots in a gc map." } ;

{ assign-gc-roots assign-derived-roots } related-words

HELP: vreg>reg
{ $values { "vreg" "virtual register" } { "reg" "register" } }
{ $description "If a live vreg is not in the pending set, then it must have been spilled." } ;

HELP: vregs>regs
{ $values { "vregs" "a sequence of virtual registers" } { "assoc" assoc } }
{ $description "Creates a mapping of virtual registers to registers." } ;

HELP: vreg>spill-slot
{ $values { "vreg" integer } { "spill-slot" spill-slot } }
{ $description "Converts a vreg number to a spill slot." } ;

ARTICLE: "compiler.cfg.linear-scan.assignment" "Assigning registers to live intervals"
"The " { $vocab-link "compiler.cfg.linear-scan.assignment" } " assigns registers to live intervals." $nl
"Vreg transformations:"
{ $subsections vreg>reg vreg>spill-slot } ;

ABOUT: "compiler.cfg.linear-scan.assignment"

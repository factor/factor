USING: assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.liveness
compiler.cfg.registers heaps help.markup help.syntax math quotations
sequences ;
IN: compiler.cfg.linear-scan.assignment

HELP: add-pending
{ $values { "live-interval" live-interval-state } }
{ $description "Adds a live interval to the pending interval set." } ;

HELP: assign-registers-in-block
{ $values { "bb" basic-block } }
{ $description "Assigns registers to vregs and also inserts " { $link ##reload } " and " { $link ##spill } " instructions." } ;

HELP: assign-registers
{ $values { "cfg" cfg } { "live-intervals" sequence } }
{ $description "Uses the live intervals in the sequence to assign physical registers to all instructions in the cfg. The live intervals must first have had their physical registers assigned by " { $link allocate-registers } "." } ;

HELP: assign-all-registers
{ $values { "insn" insn } }
{ $description "Assigns physical registers for the virtual registers used and defined by the instruction." } ;

HELP: change-insn-gc-roots
{ $values { "gc-map-insn" gc-map-insn } { "quot" quotation } }
{ $description "Applies the quotation to all vregs in the instructions " { $link gc-map } "." } ;

HELP: compute-live-in
{ $values { "bb" basic-block } }
{ $description "Computes the live in registers for a basic block." }
{ $see-also machine-live-ins } ;

HELP: emit-##call-gc
{ $values { "insn" ##call-gc } }
{ $description "Emits a " { $link ##call-gc } " instruction and the " { $link ##reload } " and " { $link ##spill } " instructions it requires. ##call-gc aren't counted as sync points, so the instruction requires special handling." } ;

HELP: expire-old-intervals
{ $values { "n" integer } { "pending-heap" min-heap } }
{ $description "Expires all intervals older than the cutoff point. First they are removed from the 'pending-heap' and " { $link pending-interval-assoc } ". Then " { $link ##spill } " instructions are inserted for each interval that was removed." } ;

HELP: insert-reload
{ $values { "live-interval" live-interval-state } }
{ $description "Inserts a " { $link ##reload } " instruction for a live interval." }
{ $see-also handle-reload insert-spill } ;

HELP: insert-spill
{ $values { "live-interval" live-interval-state } }
{ $description "Inserts a " { $link ##spill } " instruction for a live interval." }
{ $see-also insert-reload } ;

HELP: machine-edge-live-ins
{ $var-description "Mapping from basic blocks to predecessors to values which are live on a particular incoming edge." } ;

HELP: machine-live-ins
{ $var-description "Mapping from basic blocks to values which are live at the start on all incoming CFG edges. Each value is a sequence of 2-tuples where the first element is the vreg and the second the register or " { $link spill-slot } " which contains its value. It's like " { $link live-ins } " except the registers are physical instead of virtual." } ;

HELP: machine-live-outs
{ $var-description "Mapping from " { $link basic-block } " to an " { $link assoc } " of pairs which are the values that are live at the end. The keys of the pairs are virtual registers and the values are either real registers or spill slots." } ;

HELP: remove-pending
{ $values { "live-interval" live-interval-state } }
{ $description "Removes a pending live interval." } ;

HELP: unhandled-intervals
{ $var-description { $link min-heap } " of live intervals which still need a register allocation." } ;

HELP: vreg>reg
{ $values { "vreg" "virtual register" } { "reg/spill-slot" "a register or a spill slot" } }
{ $description "Translates a virtual register to a physical one. If the vreg is not in the pending set, then it must have been spilled and its spill slot is returned." }
{ $errors "Can throw a " { $link bad-vreg } " error if the vreg is not in the " { $link pending-interval-assoc } " and also doesn't have a spill slot registered." }
{ $see-also lookup-spill-slot pending-interval-assoc } ;

HELP: vregs>regs
{ $values { "assoc" "an " { $link assoc } " (set) of virtual registers" } { "assoc'" assoc } }
{ $description "Creates a mapping of virtual registers to registers." } ;

HELP: vreg>spill-slot
{ $values { "vreg" integer } { "spill-slot" spill-slot } }
{ $description "Converts a vreg number to a spill slot." } ;

ARTICLE: "compiler.cfg.linear-scan.assignment" "Assigning registers to live intervals"
"The " { $vocab-link "compiler.cfg.linear-scan.assignment" } " assigns registers to live intervals. Before this compiler pass, all values in the " { $link cfg } " were represented as simple integers called \"virtual registers\" or vregs. In this pass, using the live interval data computed in the register allocation pass (" { $vocab-link "compiler.cfg.linear-scan.allocation" } "), those vregs are translated into physical registers."
$nl
"Since there is an infinite number of vregs but the number of physical registers is limited, some values must be spilled. So this pass also handles spilling decisions and inserts " { $link ##spill } " and " { $link ##reload } " instructions where needed."
$nl
"GC maps:"
{ $subsections
  change-insn-gc-roots
  emit-##call-gc
}
"Pending intervals:"
{ $subsections
  activate-interval
  add-pending
  pending-interval-assoc
  expire-old-intervals
  remove-pending
}
"Spilling & reloading:"
{ $subsections
  insert-reload
  insert-spill
}
"Vreg transformations:"
{ $subsections
  vreg>reg
  vreg>spill-slot
  vregs>regs
} ;

ABOUT: "compiler.cfg.linear-scan.assignment"

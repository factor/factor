USING: assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.representations
cpu.architecture hash-sets help.markup help.syntax kernel math
sequences ;
IN: compiler.cfg.liveness

HELP: base-pointers
{ $var-description "Mapping from vregs to base pointer vregs. If the vreg doesn't have a base pointer, then it will be mapped to " { $link f } "." }
{ $see-also lookup-base-pointer } ;

HELP: compute-live-sets
{ $values { "cfg" cfg } }
{ $description "Main entry point for vocab. Pass must only be run after representation selection. In this pass " { $slot "gc-roots" } " are set." } ;

HELP: edge-live-ins
{ $var-description { $link assoc } " mapping basic blocks to sequences of sets of vregs; each sequence is in correspondence with a predecessor." } ;

HELP: fill-gc-map
{ $values { "live-set" assoc } { "gc-map" gc-map } }
{ $description "Assigns values to the " { $slot "gc-roots" } " and " { $slot "derived-roots" } " slots of the " { $link gc-map } ". Does nothing if the " { $link select-representations } " pass hasn't ran." } ;

HELP: gc-roots
{ $values { "live-set" assoc } { "derived-roots" hash-set } { "gc-roots" sequence } } ;

HELP: gen-uses
{ $values { "live-set" assoc } { "insn" insn } }
{ $description "Adds the vregs the instruction uses to the live set." }
{ $see-also uses-vregs } ;

HELP: kill-defs
{ $values { "live-set" assoc } { "insn" insn } }
{ $description "If liveness analysis is run after SSA destruction, we need to kill vregs that have been coalesced with others (they won't have been renamed from their original values in the CFG). Otherwise, we get a bunch of stray uses that wind up live-in/out when they shouldn't be. However, we must take care to still report the original vregs in the live-sets, because they have information associated with them (like representations) that would get lost if we just used the leaders for everything." } ;

HELP: live-in
{ $values { "bb" basic-block } { "set" assoc } }
{ $description "All the virtual registers that are live in a basic block." } ;

HELP: live-in?
{ $values { "vreg" "virtual register" } { "bb" basic-block } { "?" boolean } }
{ $description "Whether the vreg is live in the block or not." } ;

HELP: live-ins
{ $var-description "Hash that maps from basic blocks to vregs that are live in them." }
{ $see-also compute-live-sets } ;

HELP: live-outs
{ $var-description "Hash that maps from basic blocks to sets of vregs that are live after execution leaves the block. The data is computed by " { $link compute-live-sets } } ;

HELP: lookup-base-pointer
{ $values { "vreg" "vreg" } { "vreg/f" { $maybe "vreg" } } }
{ $description "Tries to figure out what the base pointer for a vreg is. Can't use cache here because of infinite recursion inside the quotation passed to cache" }
{ $see-also base-pointers } ;

HELP: visit-gc-root
{ $values
  { "vreg" integer }
  { "derived-roots" assoc }
  { "gc-roots" sequence }
}
{ $description "Handles a vreg that is live at a gc point. The vreg is handled in three ways depending on its representation:"
  { $list
    { "If it is " { $link tagged-rep } ", then the vreg contains a pointer to an object and it is added to the 'gc-roots' sequence." }
    { "If it is " { $link int-rep } " and the vreg has a base pointer, then it is added to the 'derived-roots' assoc along with that base pointer." }
    "Otherwise the vreg does not contain an object reference and nothing is done with it."
  }
}
{ $see-also lookup-base-pointer } ;

ARTICLE: "compiler.cfg.liveness" "Liveness analysis"
"Similar to http://en.wikipedia.org/wiki/Liveness_analysis, with three additions:"
$nl
{ $list
  "With SSA, it is not sufficient to have a single live-in set per block. There is also an edge-live-in set per edge, consisting of phi inputs from each predecessor."
  "Liveness analysis annotates call sites with GC maps indicating the spill slots in the stack frame that contain tagged pointers, and thus have to be visited if a GC occurs inside the call."
  { "GC maps can contain derived pointers. A derived pointer is a pointer into the middle of a data heap object. Each derived pointer has a base pointer, to keep it up to date when objects are moved by the garbage collector. This extends live intervals and inserts new " { $link ##phi } " instructions." }
}
$nl
"Querying liveness data:"
{ $subsections
  live-in live-in? live-ins
  live-out live-out? live-outs
}
"Filling GC maps:"
{ $subsections
  lookup-base-pointer
  visit-gc-root
} ;

ABOUT: "compiler.cfg.liveness"

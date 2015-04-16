USING: assocs compiler.cfg compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.representations help.markup help.syntax ;
IN: compiler.cfg.liveness

HELP: base-pointers
{ $var-description "Mapping from vregs to base pointer vregs. If the vreg doesn't have a base pointer, then it will be mapped to " { $link f } "." }
{ $see-also lookup-base-pointer } ;

HELP: fill-gc-map
{ $values { "live-set" assoc } { "gc-map" gc-map } }
{ $description "Assigns values to the " { $slot "gc-roots" } " and " { $slot "derived-roots" } " slots of the " { $link gc-map } ". Does nothing if the " { $link select-representations } " pass hasn't ran." } ;

HELP: gen-uses
{ $values { "live-set" assoc } { "insn" insn } }
{ $description "Adds the vregs the instruction uses to the live set." }
{ $see-also uses-vregs } ;

HELP: kill-defs
{ $values { "live-set" assoc } { "insn" insn } }
{ $description "If liveness analysis is run after SSA destruction, we need to kill vregs that have been coalesced with others (they won't have been renamed from their original values in the CFG). Otherwise, we get a bunch of stray uses that wind up live-in/out when they shouldn't be.  However, we must take care to still report the original vregs in the live-sets, because they have information associated with them (like representations) that would get lost if we just used the leaders for everything." } ;

HELP: live-in
{ $values { "bb" basic-block } { "set" assoc } }
{ $description "All the virtual registers that are live in a basic block." } ;

HELP: live-in?
{ $values { "vreg" "virtual register" } { "bb" basic-block } { "?" "a boolean" } }
{ $description "Whether the vreg is live in the block or not." } ;

HELP: lookup-base-pointer
{ $values { "vreg" "vreg" } { "vreg/f" "vreg or " { $link f } } }
{ $description "Tries to figure out what the base pointer for a vreg is. Can't use cache here because of infinite recursion inside the quotation passed to cache" }
{ $see-also base-pointers } ;

HELP: edge-live-ins
{ $var-description "Assoc mapping basic blocks to sequences of sets of vregs; each sequence is in correspondence with a predecessor." } ;

ARTICLE: "compiler.cfg.liveness" "Liveness analysis"
"Similar to http://en.wikipedia.org/wiki/Liveness_analysis, with three additions:"
$nl
{ $list
  "With SSA, it is not sufficient to have a single live-in set per block. There is also an edge-live-in set per edge, consisting of phi inputs from each predecessor."
  "Liveness analysis annotates call sites with GC maps indicating the spill slots in the stack frame that contain tagged pointers, and thus have to be visited if a GC occurs inside the call."
  { "GC maps can contain derived pointers. A derived pointer is a pointer into the middle of a data heap object. Each derived pointer has a base pointer, to keep it up to date when objects are moved by the garbage collector. This extends live intervals and inserts new " { $link ##phi } " instructions." }
} ;

ABOUT: "compiler.cfg.liveness"

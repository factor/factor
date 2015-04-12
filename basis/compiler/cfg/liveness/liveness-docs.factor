USING: assocs compiler.cfg compiler.cfg.instructions help.markup help.syntax ;
IN: compiler.cfg.liveness

HELP: fill-gc-map
{ $values { "live-set" "no idea" } { "insn" insn } }
{ $description "Assigns values to the " { $slot "gc-roots" } " and " { $slot "derived-roots" } " slots of an instructions " { $link gc-map } "." } ;

HELP: live-in
{ $values { "bb" basic-block } { "set" assoc } }
{ $description "All the virtual registers that are live in a basic block." } ;

HELP: live-in?
{ $values { "vreg" "virtual register" } { "bb" basic-block } { "?" "a boolean" } }
{ $description "Whether the vreg is live in the block or not." } ;

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

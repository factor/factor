USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax
sequences ;
IN: compiler.cfg.def-use

HELP: compute-insns
{ $values { "cfg" cfg } }
{ $description "Computes a mapping from vregs to the instructions that define them and store the result in the " { $link insns } " variable." } ;

HELP: defs-vregs
{ $values { "insn" insn } { "seq" sequence } }
{ $description "Returns the sequence of vregs defined, or introduced, by this instruction." }
{ $examples
  { $example
    "USING: compiler.cfg.def-use compiler.cfg.instructions compiler.cfg.registers prettyprint ;"
    "T{ ##peek f 37 D 0 0 } defs-vregs ."
    "{ 37 }"
  }
} ;

HELP: insn-of
{ $values { "vreg" "virtual register" } { "insn" insn } }
{ $description "Maps the vreg to the instruction that defined it." } ;

HELP: temp-vregs
{ $values { "insn" insn } { "seq" sequence } }
{ $description "Returns the sequence of temporary vregs used by this instruction." } ;

HELP: uses-vregs
{ $values { "insn" insn } { "seq" sequence } }
{ $description "Returns the sequence of vregs used by this instruction." }
{ $examples
  { $example
    "USING: compiler.cfg.def-use compiler.cfg.instructions compiler.cfg.registers prettyprint ;"
    "T{ ##replace f 37 D 1 6 } uses-vregs ."
    "{ 37 }"
  }
} ;

HELP: special-vreg-insns
{ $var-description "Instructions with unusual operands, also see these passes for special behavior:" { $list "compiler.cfg.renaming.functor" "compiler.cfg.representations.preferred" }
} ;

ARTICLE: "compiler.cfg.def-use" "Common code used by several passes for def-use analysis"
"The " { $vocab-link "compiler.cfg.def-use" } " contains tools to correlate SSA instructions with virtual registers defined or used by them."
$nl
"Vregs for a given instruction:"
{ $subsections
  defs-vregs
  temp-vregs
  uses-vregs
} ;

ABOUT: "compiler.cfg.def-use"

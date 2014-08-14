USING: compiler.cfg.instructions help.markup help.syntax sequences ;
IN: compiler.cfg.def-use

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

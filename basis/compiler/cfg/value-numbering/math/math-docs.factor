USING: compiler.cfg.instructions help.markup help.syntax kernel ;
IN: compiler.cfg.value-numbering.math

HELP: diagonal?
{ $values { "insn" insn } { "?" boolean } }
{ $description "Whether the two inputs to the 'insn' performing a binary operation has the same value number or not." } ;

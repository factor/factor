USING: cpu.architecture help.markup help.syntax make ;
IN: compiler.cfg.representations.conversion

HELP: tagged>rep
{ $values { "dst" "vreg" } { "src" "vreg" } { "rep" representation } }
{ $description "Emits an instruction to the current " { $link make }
  " sequence for converting a tagged value of the givern representation to an untagged one." } ;

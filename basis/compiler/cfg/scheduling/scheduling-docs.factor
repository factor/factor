USING: compiler.cfg compiler.cfg.height help.markup help.syntax sequences ;
IN: compiler.cfg.scheduling

HELP: schedule-instructions
{ $values { "cfg" cfg } }
{ $description "Performs a instruction scheduling optimization pass over the CFG to attempt to reduce the number of spills. The step must be performed after " { $link normalize-height } " or else invalid peeks might be inserted into the CFG." } ;

USING: compiler.cfg compiler.cfg.registers help.markup help.syntax math ;
IN: compiler.cfg.stacks.height

HELP: record-stack-heights
{ $values { "ds-height" number } { "rs-height" number } { "bb" basic-block } }
{ $description "Sets the data and retain stack heights in relation to the cfg of this basic block." } ;

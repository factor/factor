USING: compiler.cfg compiler.cfg.registers help.markup help.syntax math ;
IN: compiler.cfg.stacks.height

HELP: record-stack-heights
{ $values { "ds-height" number } { "rs-height" number } { "bb" basic-block } }
{ $description "Does something." } ;

HELP: ds-heights
{ $var-description "Assoc that records the data stacks height at the entry of each " { $link basic-block } "." } ;

HELP: rs-heights
{ $var-description "Assoc that records the retain stacks height at the entry of each " { $link basic-block } "." } ;

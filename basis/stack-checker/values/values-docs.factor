USING: help.markup help.syntax math quotations sequences words ;
IN: stack-checker.values

HELP: <value>
{ $values { "value" number } }
{ $description "Outputs a series of monotonically increasing numbers. They are used to assign unique ids to nodes " { $slot "in-d" } " and " { $slot "out-d" } " slots." } ;

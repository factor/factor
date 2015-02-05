USING: compiler.tree effects help.markup help.syntax math quotations ;
IN: stack-checker.recursive-state

HELP: recursive-quotation?
{ $values { "quot" quotation } }
{ $description "Checks if the quotation is among the registered recursive quotations." } ;

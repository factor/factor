USING: compiler.tree effects help.markup help.syntax kernel math quotations ;
IN: stack-checker.recursive-state

HELP: recursive-quotation?
{ $values { "quot" quotation } { "?" boolean } }
{ $description "Checks if the quotation is among the registered recursive quotations." } ;

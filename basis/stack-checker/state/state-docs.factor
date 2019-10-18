USING: help.markup help.syntax quotations sequences ;
IN: stack-checker.state

HELP: meta-d
{ $values { "stack" sequence } }
{ $description "Compile-time data stack." } ;

HELP: meta-r
{ $values { "stack" sequence } }
{ $description "Compile-time retain stack." } ;

HELP: literals
{ $var-description "Uncommitted literals. This is a form of local dead-code elimination; the goal is to reduce the number of IR nodes which get constructed. Technically it is redundant since we do global DCE later, but it speeds up compile time." } ;

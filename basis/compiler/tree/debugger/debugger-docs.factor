USING: compiler.tree help.markup help.syntax kernel quotations sequences ;
IN: compiler.tree.debugger

HELP: >R
{ $description "Symbol in the debugger to show that the top datastack item is moved to the retainstack." } ;

HELP: R>
{ $description "Symbol in the debugger to show that the top retainstack item is moved to the datastack." } ;

HELP: #>r?
{ $values { "#shuffle" #shuffle } { "?" boolean } }
{ $description "True if the #shuffle copies an item from the data stack to the retain stack." } ;

HELP: nodes>quot
{ $values { "nodes" sequence } { "quot" quotation } }
{ $description "Builds a diagnostic quotation from tree IR. Consecutive data-stack shuffles are displayed by their combined effect, eliminating redundant sequences such as " { $snippet "rot -rot swap swap" } ". Calls, literals and retain-stack transfers separate these groups."
$nl
"The result is a debugging view and can contain symbolic operations which are not executable Factor code. Composing shuffles for this view does not modify the supplied IR." } ;

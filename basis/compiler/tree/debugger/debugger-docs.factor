USING: compiler.tree help.markup help.syntax kernel ;
IN: compiler.tree.debugger

HELP: >R
{ $description "Symbol in the debugger to show that the top datastack item is moved to the retainstack." } ;

HELP: R>
{ $description "Symbol in the debugger to show that the top retainstack item is moved to the datastack." } ;

HELP: #>r?
{ $values { "#shuffle" #shuffle } { "?" boolean } }
{ $description "True if the #shuffle copies an item from the data stack to the retain stack." } ;

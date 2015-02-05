USING: compiler.tree effects help.markup help.syntax quotations sequences
stack-checker.values stack-checker.visitor ;
IN: stack-checker.state

HELP: terminated?
{ $var-description "Did the current control-flow path throw an error?" } ;

HELP: current-effect
{ $values { "effect" effect } }
{ $description "Returns what the current analysis states stack effect is." }
{ $examples
  { $example
    "USING: namespaces prettyprint stack-checker.state ;"
    "{ { input-count 2 } { terminated? t } { (meta-d) { 1 2 } } }"
    "[ current-effect ] with-variables ."
    "( x x -- x x * )"
  }
} ;

HELP: commit-literals
{ $description "Outputs all remaining literals to the current " { $link stack-visitor } " as " { $link #push } " instructions. They are also pushed onto the compile-time data stack." }
{ $see-also meta-d } ;

HELP: input-count
{ $var-description "Number of inputs current word expects from the stack." } ;

HELP: meta-d
{ $values { "stack" sequence } }
{ $description "Compile-time data stack." } ;

HELP: meta-r
{ $values { "stack" sequence } }
{ $description "Compile-time retain stack." } ;

HELP: literals
{ $var-description "Uncommitted literals. This is a form of local dead-code elimination; the goal is to reduce the number of IR nodes which get constructed. Technically it is redundant since we do global DCE later, but it speeds up compile time." } ;

HELP: (push-literal)
{ $values { "obj" "a literal" } }
{ $description "Pushes a literal value to the end of the current " { $link stack-visitor } ". The literal is also given a number and registered in the assoc of " { $link known-values } "." } ;

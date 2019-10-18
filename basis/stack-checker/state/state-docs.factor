USING: compiler.tree effects help.markup help.syntax sequences
stack-checker.backend stack-checker.values stack-checker.visitor ;
IN: stack-checker.state

HELP: (meta-d)
{ $var-description "Compile-time datastack." } ;

HELP: (meta-r)
{ $var-description "Compile-time retainstack." } ;

HELP: terminated?
{ $var-description "Did the current control-flow path throw an error?" } ;

HELP: current-effect
{ $values { "effect" effect } }
{ $description "Returns the current analysis states stack effect." }
{ $examples
  { $example
    "USING: namespaces prettyprint stack-checker.state ;"
    "{ { input-count 2 } { terminated? t } { (meta-d) { 1 2 } } { literals V{ } } }"
    "[ current-effect ] with-variables ."
    "( x x -- x x * )"
  }
} ;

HELP: commit-literals
{ $description "Outputs all remaining literals to the current " { $link stack-visitor } " as " { $link #push } " instructions. They are also pushed onto the compile-time data stack." }
{ $see-also meta-d literals } ;

HELP: input-count
{ $var-description "Number of inputs current word expects from the stack. The value is set by the word " { $link introduce-values } "." } ;

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

ARTICLE: "stack-checker.state" "Variables for holding stack effect inference state" "Variables for holding stack effect inference state. Access to the compile-time stacks:"
{ $subsections meta-d meta-r } ;

ABOUT: "stack-checker.state"

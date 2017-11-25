USING: compiler.tree effects help.markup help.syntax kernel math
quotations sequences stack-checker.state stack-checker.values
stack-checker.visitor words ;
IN: stack-checker.backend

HELP: consume-d
{ $values { "n" integer } { "seq" sequence } }
{ $description "Consumes 'n' items from the compile time data stack." }
{ $examples
  { $unchecked-example
    "USING: kernel namespaces prettyprint stack-checker.backend stack-checker.values ;"
    "0 \ <value> set-global [ 3 consume-d ] with-infer 2drop ."
    "V{ 1 2 3 }"
  }
} ;

HELP: end-infer
{ $description "Called to end the infer context. It outputs a " { $link #return } " node to the " { $link stack-visitor } " containing the remaining items on the data stack." } ;

HELP: ensure-d
{ $values { "n" integer } { "values" sequence } }
{ $description "Makes sure there is room for at least " { $snippet "n" } " items in " { $link meta-d } " starting from " { $link inner-d-index } ". Modifies " { $link meta-d } " and " { $link inner-d-index } ". Returns the last " { $snippet "n" } " items of " { $link meta-d } "." } ;

HELP: infer-literal-quot
{ $values { "literal" literal-tuple } }
{ $description "Performs inferencing for a literal quotation." }
{ $examples
  { $unchecked-example
    "[ 3 + * ] <literal> infer-literal-quot"
  }
} ;

HELP: infer-quot-here
{ $values { "quot" quotation } }
{ $description "Performs inferencing on the given quotation. This word should only be called in a " { $link with-infer } " context." } ;

HELP: introduce-values
{ $values { "values" sequence } }
{ $description "Emits an " { $link #introduce } " node to the current " { $link stack-visitor } " which pushes the given values onto the data stack." } ;

HELP: pop-d
{ $values { "obj" "object" } }
{ $description "Pops an item from the compile time datastack. If the datastack is empty, a new value is instead introduced." }
{ $see-also introduce-values } ;

HELP: pop-literal
{ $values { "obj" object } }
{ $description "Used for popping a value off the datastack which is expected to be a literal." } ;

HELP: push-d
{ $values { "obj" "object" } }
{ $description "Pushes an item onto the compile time data stack." } ;

HELP: push-literal
{ $values { "obj" "object" } }
{ $description "Pushes a literal onto the " { $link literals } " sequence." }
{ $see-also commit-literals } ;

HELP: required-stack-effect
{ $values { "word" word } { "effect" effect } }
{ $description "Gets the stack effect of the word, or throws an error if it doesn't have one." } ;

HELP: with-infer
{ $values { "quot" quotation } { "effect" effect } { "visitor" "a visitor, if any" } }
{ $description "Initializes the inference engine and then runs the given quotation which is supposed to perform the inferencing." } ;

ARTICLE: "stack-checker.backend" "Stack effect inference implementation"
"Contains words for manipulating the compile-time data and retainstacks:"
{ $subsections
  peek-d
  pop-d
  pop-literal
  pop-r
  push-d
  push-literal
  push-r
} ;

ABOUT: "stack-checker.backend"

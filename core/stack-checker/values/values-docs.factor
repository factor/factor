USING: hashtables help.markup help.syntax math quotations sequences words ;
IN: stack-checker.values

HELP: curried-effect
{ $class-description "Result of curry." } ;

HELP: composed-effect
{ $class-description "Result of compose." } ;

HELP: input-parameter
{ $class-description "Symbol used to indicate that some known value is an input parameter to the word. If it is, then the stack checker can't infer any information for it." } ;

HELP: known
{ $values { "value" number } { "known" "obj" } }
{ $description "Fetches a previously registered literal value given an abstract number." } ;

HELP: known-values
{ $var-description "A " { $link hashtable } " that maps from abstract values to literals and input parameters." }
{ $see-also input-parameter } ;

HELP: literal-tuple
{ $class-description "Represents a literal " { $link quotation } ". Its stack effect can be determined at compile-time." } ;

HELP: <literal>
{ $values { "obj" "object" } { "value" literal-tuple } }
{ $description "Creates a new literal tuple." } ;

HELP: <value>
{ $values { "value" number } }
{ $description "Outputs a series of monotonically increasing numbers. They are used to assign unique ids to nodes " { $slot "in-d" } " and " { $slot "out-d" } " slots." } ;

ARTICLE: "stack-checker.values" "Abstract stack checker values"
"When the stack checker analyzes the data and retain stacks, it only uses integer values for convenience. They are then mapped to literals and input parameters using a " { $link hashtable } "."
$nl
"Reading and writing known value data:"
{ $subsections
  copy-value
  copy-values
  known
  known-values
  make-known
  set-known
} ;

ABOUT: "stack-checker.values"

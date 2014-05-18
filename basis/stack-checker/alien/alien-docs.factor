USING: alien alien.c-types compiler.tree effects help.markup help.syntax
quotations sequences ;
IN: stack-checker.alien

HELP: alien-node-params
{ $class-description "Base class for the parameter slot of " { $link #alien-node } " nodes. It has the following slots:"
  { $table
    { { $slot "return" } { "a " { $link c-type-name } " which indicates the type of the functions return value." } }
    { { $slot "parameters" } { "a " { $link sequence } " of " { $link c-type-name } " giving the types of the functions parameters." } }
  }
} ;

HELP: param-prep-quot
{ $values { "params" alien-node-params } { "quot" quotation } }
{ $description "Builds a quotation which coerces values on the stack to the required types for the alien call." }
{ $examples
  { $example
    "USING: prettyprint stack-checker.alien ;"
    "T{ alien-invoke-params { parameters { void* c-string int } } }  param-prep-quot ."
    "[ [ [ [ ] dip >c-ptr ] dip \ utf8 string>alien ] dip >fixnum ]"
  }
} ;

HELP: infer-alien-invoke
{ $description "Appends the necessary SSA nodes for performing an " { $link alien-invoke } " call to the IR tree being constructed." } ;

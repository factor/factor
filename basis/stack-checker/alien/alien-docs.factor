USING: alien alien.c-types compiler.tree help.markup help.syntax
quotations sequences ;
IN: stack-checker.alien

HELP: alien-node-params
{ $class-description "Base class for the parameter slot of " { $link #alien-node } " nodes. It has the following slots:"
  { $slots
    { "return" { "a " { $link c-type-name } " which indicates the type of the functions return value." } }
    { "parameters" { "a " { $link sequence } " of " { $link c-type-name } " giving the types of the functions parameters." } }
    { "abi" { "calling convention of the function the node parameters operates on." } }
  }
}
{ $see-also abi } ;

HELP: alien-callback-params
{ $class-description "Class that holds the parameter types and return value type of an alien callback call." }
{ $see-also #alien-callback } ;

HELP: param-prep-quot
{ $values { "params" alien-node-params } { "quot" quotation } }
{ $description "Builds a quotation which coerces values on the stack to the required types for the alien call." }
{ $examples
  { $unchecked-example
    "USING: alien.c-types prettyprint stack-checker.alien ;"
    "T{ alien-invoke-params { parameters { void* c-string int } } } param-prep-quot ."
    "[ [ [ [ ] dip >c-ptr ] dip \\ utf8 string>alien ] dip >fixnum ]"
  }
} ;

HELP: callback-parameter-quot
{ $values { "params" alien-node-params } { "quot" quotation } }
{ $description "Builds a quotation which coerces values on the stack to the required types for an alien callback. This word is essentially the opposite to " { $link param-prep-quot } "." }
{ $examples
  { $unchecked-example
    "USING: alien.c-types prettyprint stack-checker.alien ;"
    "T{ alien-node-params { parameters { c-string } } } callback-parameter-quot ."
    "[ { object } declare [ ] dip \ utf8 alien>string ]"
  }
} ;

HELP: infer-alien-assembly
{ $description "Infers " { $link alien-assembly } " calls." } ;

HELP: infer-alien-invoke
{ $description "Appends the necessary SSA nodes for performing an " { $link alien-invoke } " call to the IR tree being constructed." } ;

HELP: wrap-callback-quot
{ $values { "params" alien-node-params } { "quot" quotation } { "quot'" quotation } }
{ $description "Wraps the given quotation in protective packaging so that it becomes suitable to be used as an alien callback. That means that the parameters are unpacked from C types to Factor types and, if the callback returns something, the top data stack item is afterwards converted to a C compatible value." }
{ $examples
  "Here a callback that returns the length of a " { $link c-string } " is wrapped:"
  { $unchecked-example
    "USING: alien.c-types prettyprint stack-checker.alien ;"
    "T{ alien-node-params { return int } { parameters { c-string } } } "
    "[ length ] wrap-callback-quot ."
    "["
    "   ["
    "       { object } declare [ ] dip \ utf8 alien>string"
    "       length >fixnum"
    "   ] ["
    "       dup current-callback eq?"
    "       [ drop ] [ wait-for-callback ] if"
    "   ] do-callback"
    "]"
  }
} ;

ARTICLE: "stack-checker.alien" "Inferring alien words" "This vocab contains code for inferring the words that form part of the alien FFI: " { $link alien-invoke } ", " { $link alien-indirect } ", " { $link alien-assembly } " and " { $link alien-callback } ". The words performing the inferring are:"
{ $subsections
  infer-alien-invoke
  infer-alien-indirect
  infer-alien-assembly
  infer-alien-callback
} ;

ABOUT: "stack-checker.alien"

USING: compiler.tree help.markup help.syntax kernel sequences words ;
IN: stack-checker.visitor

HELP: #>r,
{ $values { "inputs" sequence } { "outputs" sequence } }
{ $description "Emits a " { $link #shuffle } " node that copies values from the data stack to the retain stack. This node is primarily outputted by the " { $link dip } " word and its relatives." }
{ $examples
  { $example
    "USING: namespaces prettyprint stack-checker.visitor ;"
    "V{ } stack-visitor set { 123 } { 124 } #>r, stack-visitor get ."
    "V{\n    T{ #shuffle\n        { mapping { { 124 123 } } }\n        { in-d { 123 } }\n        { out-r { 124 } }\n    }\n}"
  }
} ;

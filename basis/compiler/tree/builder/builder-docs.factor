USING: compiler.tree help.markup help.syntax literals quotations
sequences splitting stack-checker.errors words ;
IN: compiler.tree.builder

HELP: build-tree
{ $values { "word/quot" { $or word quotation } } { "nodes" "a sequence of nodes" } }
{ $description "Attempts to construct tree SSA IR from a quotation." }
{ $notes "This is the first stage of the compiler." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

HELP: build-sub-tree
{ $values { "in-d" "a sequence of values" } { "out-d" "a sequence of values" } { "word/quot" { $or word quotation } } { "nodes/f" { $maybe "a sequence of nodes" } } }
{ $description "Attempts to construct tree SSA IR from a quotation, starting with an initial data stack of values from the call site. Outputs " { $link f } " if stack effect inference fails." }
{ $examples
  { $unchecked-example
    ! The out-d numbers are unpredicable.
    "USING: compiler.tree.builder math prettyprint ;"
    "{ \"x\" } { \"y\" } [ 4 * ] build-sub-tree ."
    $[
        {
            "V{"
            "    T{ #push { literal 4 } { out-d { 1 } } }"
            "    T{ #call { word * } { in-d V{ \"x\" 1 } } { out-d { 2 } } }"
            "    T{ #copy { in-d V{ 2 } } { out-d { \"y\" } } }"
            "}"
        } join-lines
    ]
  }
} ;

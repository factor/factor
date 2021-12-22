USING: help.markup help.syntax literals multiline ;
IN: compiler.tree.propagation

HELP: propagate
{ $values { "nodes" "a sequence of nodes" } }
{ $description "Performs the propagation pass of the AST optimization. All nodes info slots are initialized here." }
{ $examples {
    $unchecked-example
        "USING: compiler.tree.builder compiler.tree.propagation math prettyprint ;"
        "[ 3 + ] build-tree propagate third ..."
        [[ T{ #call
    { word + }
    { in-d V{ 25685700 25685699 } }
    { out-d { 25685701 } }
    { info
        H{
            {
                25685699
                T{ value-info-state
                    { class fixnum }
                    { interval
                        T{ interval
                            { from { 3 t } }
                            { to { 3 t } }
                        }
                    }
                    { literal 3 }
                    { literal? t }
                }
            }
            {
                25685700
                T{ value-info-state
                    { class object }
                    { interval full-interval }
                }
            }
            {
                25685701
                T{ value-info-state
                    { class number }
                    { interval full-interval }
                }
            }
        }
    }
}]] } } ;

ARTICLE: "compiler.tree.propagation" "Class, interval, constant propagation"
"This pass must be run after " { $vocab-link "compiler.tree.normalization" } "." ;

ABOUT: "compiler.tree.propagation"

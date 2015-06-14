USING: help.markup help.syntax literals multiline ;
IN: compiler.tree.propagation

<<
STRING: propagate-ex
USING: compiler.tree.builder compiler.tree.propagation math prettyprint ;
[ 3 + ] build-tree propagate third .
T{ #call
    { word + }
    { in-d V{ 9450187 9450186 } }
    { out-d { 9450188 } }
    { info
        H{
            {
                9450186
                T{ value-info-state
                    { class fixnum }
                    { interval
                        T{ interval
                            { from ~array~ }
                            { to ~array~ }
                        }
                    }
                    { literal 3 }
                    { literal? t }
                }
            }
            {
                9450187
                T{ value-info-state
                    { class object }
                    { interval full-interval }
                }
            }
            {
                9450188
                T{ value-info-state
                    { class number }
                    { interval full-interval }
                }
            }
        }
    }
}
;
>>

HELP: propagate
{ $values { "nodes" "a sequence of nodes" } }
{ $description "Performs the propagation pass of the AST optimization. All nodes info slots are initialized here." }
{ $examples { $unchecked-example $[ propagate-ex ] }
} ;

ARTICLE: "compiler.tree.propagation" "Class, interval, constant propagation"
"This pass must be run after " { $vocab-link "compiler.tree.normalization" } "." ;

ABOUT: "compiler.tree.propagation"

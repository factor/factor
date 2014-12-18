USING: assocs compiler.cfg compiler.cfg.builder.blocks
compiler.cfg.stacks.local compiler.tree help.markup help.syntax literals math
multiline sequences vectors words ;
IN: compiler.cfg.builder

<<
STRING: ex-emit-call
USING: compiler.cfg.builder compiler.cfg.builder.blocks compiler.cfg.stacks
kernel make prettyprint ;
begin-stack-analysis initial-basic-block \ dummy 3 [ emit-call ] { } make drop
current-height basic-block [ get . ] bi@ .
T{ current-height { d 3 } }
T{ basic-block
    { id 134 }
    { successors
        V{
            T{ basic-block
                { id 135 }
                { instructions
                    V{
                        T{ ##call { word dummy } }
                        T{ ##branch }
                    }
                }
                { successors V{ T{ basic-block { id 136 } } } }
                { kill-block? t }
            }
        }
    }
}
;

STRING: ex-make-input-map
USING: compiler.cfg.builder prettyprint ;
T{ #shuffle { in-d { 37 81 92 } } } make-input-map .
H{
    { 81 T{ ds-loc { n 1 } } }
    { 37 T{ ds-loc { n 2 } } }
    { 92 T{ ds-loc } }
}
;
>>

HELP: procedures
{ $var-description "A " { $link vector } " used as temporary storage during cfg construction for all procedures being built." } ;

HELP: make-input-map
{ $values { "#shuffle" #shuffle } { "assoc" assoc } }
{ $description "Creates an " { $link assoc } " that maps input values to the shuffle operation to stack locations." }
{ $examples { $unchecked-example $[ ex-make-input-map ] } } ;

HELP: emit-call
{ $values { "word" word } { "height" number } }
{ $description "Emits a call to the given word to the " { $link cfg } " being constructed. \"height\" is the number of items being added to or removed from the data stack. Side effects of the word is that it modifies the \"basic-block\" and " { $link current-height } " variables." }
{ $examples
  "In this example, a call to a dummy word is emitted which pushes three items onto the stack."
  { $unchecked-example $[ ex-emit-call ] }
}
{ $see-also call-height } ;

HELP: emit-node
{ $values { "node" node } }
{ $description "Emits CFG instructions for the given SSA node." } ;

HELP: trivial-branch?
{ $values
  { "nodes" "a " { $link sequence } " of " { $link node } " instances" }
  { "value" "the pushed value or " { $link f } }
  { "?" "a boolean" }
}
{ $description "Checks whether nodes is a trivial branch or not. The branch is counted as trivial if all it does is push a literal value on the stack." }
{ $examples
  { $example
    "USING: compiler.cfg.builder compiler.tree prettyprint ;"
    "{ T{ #push { literal 25 } } } trivial-branch? . ."
    "t\n25"
  }
} ;

HELP: build-cfg
{ $values { "nodes" sequence } { "word" word } { "procedures" sequence } }
{ $description "Builds one or more cfgs from the given word." } ;

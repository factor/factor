USING: compiler.tree help.markup help.syntax sequences words ;
IN: compiler.cfg.builder

HELP: emit-node
{ $values { "node" node } }
{ $description "Emits some kind of code for the node." } ;

HELP: trivial-branch?
{ $values
  { "nodes" "a " { $link sequence } " of " { $link node } " instances" }
  { "value" "the pushed value or " { $link f } }
  { "?" "a boolean" }
}
{ $description "Checks whether nodes is a trivial branch or not. The branch is counted as trivial if all it does is push a literal value on the stack." }
{ $examples
  { $example
    "USING: compiler.cfg.builder prettyprint ;"
    "{ T{ #push { literal 25 } } } trivial-branch? . ."
    "t\n25"
  }
} ;

HELP: build-cfg
{ $values { "nodes" sequence } { "word" word } { "procedures" sequence } }
{ $description "Builds one or more cfgs from the given word." } ;

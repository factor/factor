USING: assocs compiler.tree help.markup help.syntax kernel ;
IN: compiler.tree.finalization

ARTICLE: "compiler.tree.finalization" "Final pass cleans up high-level IR"
"This is a late-stage optimization. See the vocab " { $vocab-link "compiler.tree.late-optimizations" } "."
$nl
"This pass runs after propagation, so that it can expand type predicates; these cannot be expanded before propagation since we need to see 'fixnum?' instead of 'tag 0 eq?' and so on, for semantic reasoning."
$nl
"We also delete empty stack shuffles and copies to facilitate tail call optimization in the code generator." ;

ABOUT: "compiler.tree.finalization"

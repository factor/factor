USING: compiler.tree help.markup help.syntax words ;
IN: compiler.cfg.intrinsics
HELP: emit-intrinsic
{ $values { "node" node } { "word" word } }
{ $description "Emit optimized intrinsic code for a word instead of merely calling it. The \"intrinsic\" property of the word (which is expected to be a quotation) is called with the node as input." } ;

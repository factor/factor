USING: assocs compiler.tree help.markup help.syntax kernel ;
IN: compiler.tree.late-optimizations

ARTICLE: "compiler.tree.late-optimizations" "Utilities used by several optimization passes run in the later stages"
"Late optimizations modify the tree such that stack flow information is no longer accurate, since we punt in " { $link splice-quot } " and don't update everything that we should; this simplifies the code, improves performance, and we don't need the stack flow information after this pass anyway." ;

ABOUT: "compiler.tree.late-optimizations"

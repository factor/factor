USING: assocs compiler.tree help.markup help.syntax kernel ;
IN: compiler.tree.normalization

ARTICLE: "compiler.tree.normalization" "Normalize IR created by high level IR builder to simplify subsequent passes"
"A transform pass done before optimization can begin to fix up some oddities in the tree output by the stack checker:"
{ $list
  {
      "We rewrite the code so that all " { $link #introduce } " nodes are replaced with a single one, at the beginning of a program. This simplifies subsequent analysis." }
  { "We normalize " { $link #call-recursive } " as follows. The stack checker says that the inputs of a #call-recursive are the entire stack at the time of the call. This is a conservative estimate; we don't know the exact number of stack values it touches until the " { $link #return-recursive } " node has been visited, because of row polymorphism. So in the normalize pass, we split a #call-recursive into a #copy of the unchanged values and a #call-recursive with trimmed inputs and outputs." }
} ;

ABOUT: "compiler.tree.normalization"

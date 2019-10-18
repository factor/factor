USING: compiler.tree help.markup help.syntax kernel quotations words ;
IN: compiler.tree.propagation.inlining

HELP: (do-inlining)
{ $values { "#call" #call } { "word" word } { "?" boolean } }
{ $description
  "Performs inlining of a word."
  $nl
  "If the generic was defined in an outer compilation unit, then it doesn't have a definition yet; the definition is built at the end of the compilation unit. We do not attempt inlining at this stage since the stack discipline is not finalized yet, so dispatch# might return an out of bounds value. This case comes up if a parsing word calls the compiler at parse time (doing so is discouraged, but it should still work.)"
} ;

HELP: custom-inlining?
{ $values { "word" word } { "quot/f" "a quotation or " { $link f } } }
{ $description "Returns the custom inlining " { $link quotation } " for a word if it has one." } ;

HELP: do-inlining
{ $values { "#call" #call } { "word" word } { "?" boolean } }
{ $description "Performs inlining of the word in the #call node. If there's a custom inlining hook, it is permitted to return f, which means that we try the normal inlining heuristic." } ;

HELP: inline-math-method
{ $values { "#call" #call } { "word" word } { "?" boolean } }
{ $description "Inlines a generic math word." } ;

ARTICLE: "compiler.tree.propagation.inlining" "Method inlining and dispatch elimination"
"Splicing nodes:"
{ $subsections splicing-call open-code-#call splicing-body } ;

ABOUT: "compiler.tree.propagation.inlining"

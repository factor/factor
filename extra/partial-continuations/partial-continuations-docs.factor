IN: partial-continuations
USING: help.markup help.syntax kernel ;

HELP: breset
{ $values { "quot" { $quotation ( r -- v ) } } }
{ $description "Marks the boundary of the partial continuation. The quotation has stack effect " { $snippet "( r -- v )" } ", where " { $snippet "r" } " identifies the " { $link breset } " in scope and should be passed to " { $link bshift } " to mark the boundary of the continuation." }
{ $notes "It is important to note that even if the quotation discards items on the stack, the stack will be restored to the way it was before it is called (which is true of continuation usage in general)." } ;

HELP: bshift
{ $values { "r" "the " { $link breset } " in scope" } { "quot" { $quotation ( pcc -- v ) } } }
{ $description "Calls the quotation with the partial continuation on the stack. The quotation should have stack effect " { $snippet "( pcc -- v )" } ". The partial continuation can be called with " { $link call } " and has stack effect " { $snippet "( a -- b )" } "." }
{ $notes "It is important to note that even if the quotation discards items on the stack, the stack will be restored to the way it was before it is called (which is true of continuation usage in general)." } ;

ARTICLE: "partial-continuations" "Partial continuations"
"Based on Scheme code for bshift and breset from "
{ $url "http://groups.google.com/group/comp.lang.scheme/msg/9f0d61da01540816" } "."
" See this blog entry for more details:"
{ $url "http://www.bluishcoder.co.nz/2006/03/factor-partial-continuation-updates.html" }
{ $subsections
    breset
    bshift
} ;

ABOUT: "partial-continuations"

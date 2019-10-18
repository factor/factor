USING: help.syntax help.markup kernel sequences ;
IN: sequences.deep

HELP: deep-each
{ $values { "obj" object } { "quot" { $quotation ( ... elt -- ... ) } } }
{ $description "Execute a quotation on each nested element of an object and its children, in preorder." }
{ $see-also each } ;

HELP: deep-reduce
{ $values { "obj" object } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "result" "the final result" } }
{ $description "Execute a quotation on each nested element of an object and its children, in preorder. The first iteration is called with " { $code "identity" } " and the first element. Subsequence iterations are called with the result of the previous iteration and the next element." }
{ $see-also reduce } ;

HELP: deep-map
{ $values { "obj" object } { "quot" { $quotation ( ... elt -- ... elt' ) } } { "newobj" "the mapped object" } }
{ $description "Execute a quotation on each nested element of an object and its children, in preorder. That is, the result of the execution of the quotation on the outer is used to map the inner elements." }
{ $see-also map } ;

HELP: deep-filter-as
{ $values { "obj" object } { "quot" { $quotation ( ... elt -- ... ? ) } } { "exemplar" sequence } { "seq" sequence } }
{ $description "Creates a sequence (of the same type as " { $snippet "exemplar" } ") of sub-nodes in the object which satisfy the given quotation, in preorder. This includes the object itself, if it passes the quotation." } ;

HELP: deep-filter
{ $values { "obj" object } { "quot" { $quotation ( ... elt -- ... ? ) } } { "seq" sequence } }
{ $description "Creates a sequence of sub-nodes in the object which satisfy the given quotation, in preorder. This includes the object itself, if it passes the quotation." }
{ $see-also filter } ;

HELP: deep-find
{ $values { "obj" object } { "quot" { $quotation ( ... elt -- ... ? ) } } { "elt" "an element" } }
{ $description "Gets the first sub-node of the object, in preorder, which satisfies the quotation. If nothing satisfies it, it returns " { $link f } "." }
{ $see-also find } ;

HELP: deep-any?
{ $values { "obj" object } { "quot" { $quotation ( ... elt -- ... ? ) } } { "?" boolean } }
{ $description "Tests whether the given object or any subnode satisfies the given quotation." }
{ $see-also any? } ;

HELP: flatten-as
{ $values { "obj" object } { "exemplar" sequence } { "seq" sequence } }
{ $description "Creates a sequence (of the same type as " { $snippet "exemplar" } ") of all of the leaf nodes (non-sequence nodes, but including strings and numbers) in the object." } ;

HELP: flatten
{ $values { "obj" object } { "seq" sequence } }
{ $description "Creates a sequence of all of the leaf nodes (non-sequence nodes, but including strings and numbers) in the object." } ;

HELP: deep-map!
{ $values { "obj" object } { "quot" { $quotation ( ... elt -- ... elt' ) } } }
{ $description "Modifies each sub-node of an object in place, in preorder, and returns that object." }
{ $see-also map! } ;

ARTICLE: "sequences.deep" "Deep sequence combinators"
"The combinators in the " { $vocab-link "sequences.deep" } " vocabulary are variants of standard sequence combinators which traverse nested subsequences."
{ $subsections
    deep-each
    deep-map
    deep-filter
    deep-find
    deep-any?
    deep-map!
}
"A utility word to collapse nested subsequences:"
{ $subsections flatten } ;

ABOUT: "sequences.deep"

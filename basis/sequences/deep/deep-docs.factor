USING: help.syntax help.markup kernel sequences ;
IN: sequences.deep

HELP: deep-each
{ $values { "obj" object } { "quot" { $quotation "( elt -- )" } } }
{ $description "Execute a quotation on each nested element of an object and its children, in preorder." }
{ $see-also each } ;

HELP: deep-map
{ $values { "obj" object } { "quot" { $quotation "( elt -- newelt )" } } { "newobj" "the mapped object" } }
{ $description "Execute a quotation on each nested element of an object and its children, in preorder. That is, the result of the execution of the quotation on the outer is used to map the inner elements." }
{ $see-also map }  ;

HELP: deep-filter
{ $values { "obj" object } { "quot" { $quotation "( elt -- ? )" } } { "seq" "a sequence" } }
{ $description "Creates a sequence of sub-nodes in the object which satisfy the given quotation, in preorder. This includes the object itself, if it passes the quotation." }
{ $see-also filter }  ;

HELP: deep-find
{ $values { "obj" object } { "quot" { $quotation "( elt -- ? )" } } { "elt" "an element" } }
{ $description "Gets the first sub-node of the object, in preorder, which satisfies the quotation. If nothing satisifies it, it returns " { $link f } "." }
{ $see-also find }  ;

HELP: deep-any?
{ $values { "obj" object } { "quot" { $quotation "( elt -- ? )" } } { "?" "a boolean" } }
{ $description "Tests whether the given object or any subnode satisfies the given quotation." }
{ $see-also any? } ;

HELP: flatten
{ $values { "obj" object } { "seq" "a sequence" } }
{ $description "Creates a sequence of all of the leaf nodes (non-sequence nodes, but including strings and numbers) in the object." } ;

HELP: deep-change-each
{ $values { "obj" object } { "quot" { $quotation "( elt -- newelt )" } } }
{ $description "Modifies each sub-node of an object in place, in preorder." }
{ $see-also change-each } ;

ARTICLE: "sequences.deep" "Deep sequence combinators"
"The combinators in the " { $vocab-link "sequences.deep" } " vocabulary are variants of standard sequence combinators which traverse nested subsequences."
{ $subsections
    deep-each
    deep-map
    deep-filter
    deep-find
    deep-any?
    deep-change-each
}
"A utility word to collapse nested subsequences:"
{ $subsections flatten } ;

ABOUT: "sequences.deep"

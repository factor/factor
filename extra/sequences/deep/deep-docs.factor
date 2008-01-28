USING: help.syntax help.markup ;
IN: sequences.deep

HELP: deep-each
{ $values { "obj" "an object" } { "quot" "a quotation ( elt -- ) " } }
{ $description "Execute a quotation on each nested element of an object and its children, in preorder." } ;

HELP: deep-map
{ $values { "obj" "an object" } { "quot" "a quotation ( elt -- newelt )" } { "newobj" "the mapped object" } }
{ $description "Execute a quotation on each nested element of an object and its children, in preorder. That is, the result of the execution of the quotation on the outer is used to map the inner elements." } ;

HELP: deep-subset
{ $values { "obj" "an object" } { "quot" "a quotation ( elt -- ? )" } { "seq" "a sequence" } }
{ $description "Creates a sequence of sub-nodes in the object which satisfy the given quotation, in preorder. This includes the object itself, if it passes the quotation." } ;

HELP: deep-find
{ $values { "obj" "an object" } { "quot" "a quotation ( elt -- ? )" } { "elt" "an element" } }
{ $description "Gets the first sub-node of the object, in preorder, which satisfies the quotation. If nothing satisifies it, it returns " { $link f } "." } ;

HELP: deep-contains?
{ $values { "obj" "an object" } { "quot" "a quotation ( elt -- ? )" } { "?" "a boolean" } }
{ $description "Tests whether the given object or any subnode satisfies the given quotation." } ;

HELP: flatten
{ $values { "obj" "an object" } { "seq" "a sequence" } }
{ $description "Creates a sequence of all of the leaf nodes (non-sequence nodes, but including strings and numbers) in the object." } ;

HELP: deep-change-each
{ $values { "obj" "an object" } { "quot" "a quotation ( elt -- newelt )" } }
{ $description "Modifies each sub-node of an object in place, in preorder." } ;

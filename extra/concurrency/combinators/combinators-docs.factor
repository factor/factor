USING: help.markup help.syntax sequences ;
IN: concurrency.combinators

HELP: parallel-map
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- newelt )" } } { "newseq" sequence } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to every element of " { $snippet "seq" } ", collecting the results at the end." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: parallel-each
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- )" } } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to every element of " { $snippet "seq" } ", blocking until all quotations complete." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: parallel-subset
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- ? )" } } { "newseq" sequence } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to every element of " { $snippet "seq" } ", collecting the elements for which the quotation yielded a true value." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

ARTICLE: "concurrency.combinators" "Concurrent combinators"
"The " { $vocab-link "concurrency.combinators" } " vocabulary provides concurrent variants of " { $link each } ", " { $link map } " and " { $link subset } ":"
{ $subsection parallel-each }
{ $subsection parallel-map }
{ $subsection parallel-subset } ;

ABOUT: "concurrency.combinators"

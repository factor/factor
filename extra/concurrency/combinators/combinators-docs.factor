USING: help.markup help.syntax sequences ;
IN: concurrency.combinators

HELP: parallel-map
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- newelt )" } } { "newseq" sequence } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to every element of " { $snippet "seq" } ", collecting the results at the end." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: 2parallel-map
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- newelt )" } } { "newseq" sequence } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to pairwise elements of " { $snippet "seq1" } " and " { $snippet "seq2" } ", collecting the results at the end." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: parallel-each
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- )" } } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to every element of " { $snippet "seq" } ", blocking until all quotations complete." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: 2parallel-each
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- )" } } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to pairwise elements of " { $snippet "seq1" } " and " { $snippet "seq2" } ", blocking until all quotations complete." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: parallel-filter
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- ? )" } } { "newseq" sequence } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to every element of " { $snippet "seq" } ", collecting the elements for which the quotation yielded a true value." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

ARTICLE: "concurrency.combinators" "Concurrent combinators"
"The " { $vocab-link "concurrency.combinators" } " vocabulary provides concurrent variants of " { $link each } ", " { $link map } " and " { $link filter } ":"
{ $subsection parallel-each }
{ $subsection 2parallel-each }
{ $subsection parallel-map }
{ $subsection 2parallel-map }
{ $subsection parallel-filter } ;

ABOUT: "concurrency.combinators"

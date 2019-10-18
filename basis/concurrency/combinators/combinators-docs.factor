USING: help.markup help.syntax sequences ;
IN: concurrency.combinators

HELP: parallel-map
{ $values { "seq" sequence } { "quot" { $quotation ( elt -- newelt ) } } { "newseq" sequence } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to every element of " { $snippet "seq" } ", collecting the results at the end." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: 2parallel-map
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( elt1 elt2 -- newelt ) } } { "newseq" sequence } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to pairwise elements of " { $snippet "seq1" } " and " { $snippet "seq2" } ", collecting the results at the end." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: parallel-each
{ $values { "seq" sequence } { "quot" { $quotation ( elt -- ) } } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to every element of " { $snippet "seq" } ", blocking until all quotations complete." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: 2parallel-each
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( elt1 elt2 -- ) } } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to pairwise elements of " { $snippet "seq1" } " and " { $snippet "seq2" } ", blocking until all quotations complete." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

HELP: parallel-filter
{ $values { "seq" sequence } { "quot" { $quotation ( elt -- ? ) } } { "newseq" sequence } }
{ $description "Spawns a new thread for applying " { $snippet "quot" } " to every element of " { $snippet "seq" } ", collecting the elements for which the quotation yielded a true value." }
{ $errors "Throws an error if one of the iterations throws an error." } ;

ARTICLE: "concurrency.combinators" "Concurrent combinators"
"The " { $vocab-link "concurrency.combinators" } " vocabulary provides concurrent variants of various combinators."
$nl
"Concurrent sequence combinators:"
{ $subsections
    parallel-each
    2parallel-each
    parallel-map
    2parallel-map
    parallel-filter
}
"Concurrent product sequence combinators:"
{ $subsections
    parallel-product-each
    parallel-cartesian-each
    parallel-product-map
    parallel-cartesian-map
}
"Concurrent cleave combinators:"
{ $subsections
    parallel-cleave
    parallel-spread
    parallel-napply
}
"The " { $vocab-link "concurrency.semaphores" } " vocabulary can be used in conjunction with the above combinators to limit the maximum number of concurrent operations." ;

ABOUT: "concurrency.combinators"

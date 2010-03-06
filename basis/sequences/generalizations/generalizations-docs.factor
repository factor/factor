! (c)2009 Joe Groff bsd license
USING: help.syntax help.markup kernel sequences quotations
math arrays combinators ;
IN: sequences.generalizations

HELP: neach
{ $values { "seq..." { $snippet "n" } " sequences on the datastack" } { "quot" "a quotation with stack effect " { $snippet "( element... -- )" } } { "n" integer } }
{ $description "A generalization of " { $link each } ", " { $link 2each } ", and " { $link 3each } " that can iterate over any number of sequences in parallel." } ;

HELP: nmap
{ $values { "seq..." { $snippet "n" } " sequences on the datastack" } { "quot" "a quotation with stack effect " { $snippet "( element... -- result )" } } { "n" integer } { "result" "a sequence of the same type as the first " { $snippet "seq" } } }
{ $description "A generalization of " { $link map } ", " { $link 2map } ", and " { $link 3map } " that can map over any number of sequences in parallel." } ;

HELP: nmap-as
{ $values { "seq..." { $snippet "n" } " sequences on the datastack" } { "quot" "a quotation with stack effect " { $snippet "( element... -- result )" } } { "exemplar" sequence } { "n" integer } { "result" "a sequence of the same type as " { $snippet "exemplar" } } }
{ $description "A generalization of " { $link map-as } ", " { $link 2map-as } ", and " { $link 3map-as } " that can map over any number of sequences in parallel." } ;

HELP: mnmap
{ $values { "m*seq" { $snippet "m" } " sequences on the datastack" } { "quot" "a quotation with stack effect " { $snippet "( m*element -- result*n )" } } { "m" integer } { "n" integer } { "result*n" { $snippet "n" } " sequences of the same type as the first " { $snippet "seq" } } }
{ $description "A generalization of " { $link map } ", " { $link 2map } ", and " { $link 3map } " that can map over any number of sequences in parallel and provide any number of output sequences." } ;

HELP: mnmap-as
{ $values { "m*seq" { $snippet "m" } " sequences on the datastack" } { "quot" "a quotation with stack effect " { $snippet "( m*element -- result*n )" } } { "n*exemplar" { $snippet "n" } " sequences on the datastack" } { "m" integer } { "n" integer } { "result*n" { $snippet "n" } " sequences on the datastack of the same types as the " { $snippet "exemplar" } "s" } }
{ $description "A generalization of " { $link map-as } ", " { $link 2map-as } ", and " { $link 3map-as } " that can map over any number of sequences in parallel and provide any number of output sequences of distinct types." } ;

HELP: nproduce
{ $values { "pred" { $quotation "( -- ? )" } } { "quot" { $quotation "( -- obj1 obj2 ... objn )" } } { "n" integer } { "seq..." { $snippet "n" } " arrays on the datastack" } }
{ $description "A generalization of " { $link produce } " that generates " { $snippet "n" } " arrays in parallel by calling " { $snippet "quot" } " repeatedly until " { $snippet "pred" } " outputs false." } ;

HELP: nproduce-as
{ $values { "pred" { $quotation "( -- ? )" } } { "quot" { $quotation "( -- obj1 obj2 ... objn )" } } { "exemplar..." { $snippet "n" } " sequences on the datastack" } { "n" integer } { "seq..." { $snippet "n" } " sequences on the datastack of the same types as the " { $snippet "exemplar" } "s" } }
{ $description "A generalization of " { $link produce-as } " that generates " { $snippet "n" } " sequences in parallel by calling " { $snippet "quot" } " repeatedly until " { $snippet "pred" } " outputs false." } ;

ARTICLE: "sequences.generalizations" "Generalized sequence iteration combinators"
"The " { $vocab-link "sequences.generalizations" } " vocabulary defines generalized versions of the iteration " { $link "sequences-combinators" } "."
{ $subsections
    neach
    nmap
    nmap-as
    mnmap
    mnmap-as
    nproduce
    nproduce-as
} ;

ABOUT: "sequences.generalizations"

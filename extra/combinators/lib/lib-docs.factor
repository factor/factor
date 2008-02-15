USING: help.syntax help.markup kernel prettyprint sequences
quotations math ;
IN: combinators.lib

HELP: generate
{ $values { "generator" quotation } { "predicate" quotation } { "obj" object } }
{ $description "Loop until the generator quotation generates an object that satisfies predicate quotation." }
{ $unchecked-example
    "! Generate a random 20-bit prime number congruent to 3 (mod 4)"
    "USE: math.miller-rabin"
    "[ 20 random-prime ] [ 4 mod 3 = ] generate ."
    "526367"
} ;

HELP: ndip
{ $values { "quot" quotation } { "n" number } }
{ $description "A generalisation of " { $link dip } " that can work " 
"for any stack depth. The quotation will be called with a stack that "
"has 'n' items removed first. The 'n' items are then put back on the "
"stack. The quotation can consume and produce any number of items."
} 
{ $examples
  { $example "USE: combinators.lib" "1 2 [ dup ] 1 ndip .s" "1\n1\n2" }
  { $example "USE: combinators.lib" "1 2 3 [ drop ] 2 ndip .s" "2\n3" }
}
{ $see-also dip dipd } ;

HELP: nslip
{ $values { "n" number } }
{ $description "A generalisation of " { $link slip } " that can work " 
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"removed from the stack, the quotation called, and the items restored."
} 
{ $examples
  { $example "USE: combinators.lib" "[ 99 ] 1 2 3 4 5 5 nslip .s" "99\n1\n2\n3\n4\n5" }
}
{ $see-also slip nkeep } ;

HELP: nkeep
{ $values { "quot" quotation } { "n" number } }
{ $description "A generalisation of " { $link keep } " that can work " 
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"saved, the quotation called, and the items restored."
} 
{ $examples
  { $example "USE: combinators.lib" "1 2 3 4 5 [ drop drop drop drop drop 99 ] 5 nkeep .s" "99\n1\n2\n3\n4\n5" }
}
{ $see-also keep nslip } ;

HELP: &&
{ $values { "quots" "a sequence of quotations with stack effect " { $snippet "( ... -- ... ? )" } } { "?" "a boolean" } }
{ $description "Calls each quotation in turn; outputs " { $link f } " if one of the quotations output " { $link f } ", otherwise outputs " { $link t } ". As soon as a quotation outputs " { $link f } ", evaluation stops and subsequent quotations are not called." } ;

HELP: ||
{ $values { "quots" "a sequence of quotations with stack effect " { $snippet "( ... -- ... ? )" } } { "?" "a boolean" } }
{ $description "Calls each quotation in turn; outputs " { $link t } " if one of the quotations output " { $link t } ", otherwise outputs " { $link f } ". As soon as a quotation outputs " { $link t } ", evaluation stops and subsequent quotations are not called." } ;

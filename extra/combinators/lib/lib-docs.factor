USING: help.syntax help.markup kernel prettyprint sequences ;
IN: combinators.lib

HELP: generate
{ $values { "generator" "a quotation" } { "predicate" "a quotation" } { "obj" "an object" } }
{ $description "Loop until the generator quotation generates an object that satisfies predicate quotation." }
{ $unchecked-example
    "! Generate a random 20-bit prime number congruent to 3 (mod 4)"
    "USE: math.miller-rabin"
    "[ 20 random-prime ] [ 4 mod 3 = ] generate ."
    "526367"
} ;

HELP: ndip
{ $values { "quot" "a quotation" } { "n" "a number" } }
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
{ $values { "n" "a number" } }
{ $description "A generalisation of " { $link slip } " that can work " 
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"removed from the stack, the quotation called, and the items restored."
} 
{ $examples
  { $example "USE: combinators.lib" "[ 99 ] 1 2 3 4 5 5 nslip .s" "99\n1\n2\n3\n4\n5" }
}
{ $see-also slip nkeep } ;

HELP: nkeep
{ $values { "quot" "a quotation" } { "n" "a number" } }
{ $description "A generalisation of " { $link keep } " that can work " 
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"saved, the quotation called, and the items restored."
} 
{ $examples
  { $example "USE: combinators.lib" "1 2 3 4 5 [ drop drop drop drop drop 99 ] 5 nkeep .s" "99\n1\n2\n3\n4\n5" }
}
{ $see-also keep nslip } ;

HELP: map-withn
{ $values { "seq" "a sequence" } { "quot" "a quotation" } { "n" "a number" } { "newseq" "a sequence" } }
{ $description "A generalisation of " { $link map } ". The first " { $snippet "n" } " items after the quotation will be "
"passed to the quotation given to map-withn for each element in the sequence."
} 
{ $examples
  { $example "USE: combinators.lib" "1 2 3 4 { 6 7 8 9 10 } [ + + + + ] 4 map-withn .s" "{ 16 17 18 19 20 }" }
}
{ $see-also each-withn } ;

HELP: each-withn
{ $values { "seq" "a sequence" } { "quot" "a quotation" } { "n" "a number" } }
{ $description "A generalisation of " { $link each } ". The first " { $snippet "n" } " items after the quotation will be "
"passed to the quotation given to each-withn for each element in the sequence."
} 
{ $see-also map-withn } ;

HELP: sigma
{ $values { "seq" "a sequence" } { "quot" "a quotation" } }
{ $description "Like map sum, but without creating an intermediate sequence." }
{ $example
    "! Find the sum of the squares [0,99]"
    "USE: math.ranges"
    "100 [1,b] [ sq ] sigma"
    "338350"
} ;

HELP: count
{ $values { "seq" "a sequence" } { "quot" "a quotation" } }
{ $description "Efficiently returns the number of elements that the predicate quotation matches." }
{ $example
    "USE: math.ranges"
    "100 [1,b] [ even? ] count ."
    "50"
} ;

HELP: all-unique?
{ $values { "seq" "a sequence" } { "?" "a boolean" } }
{ $description "Tests whether a sequence contains any repeated elements." }
{ $example
    "{ 0 1 1 2 3 5 } all-unique? ."
    "f"
} ;

HELP: &&
{ $values { "quots" "a sequence of quotations with stack effect " { $snippet "( ... -- ... ? )" } } }
{ $description "Calls each quotation in turn; outputs " { $link f } " if one of the quotations output " { $link f } ", otherwise outputs " { $link t } ". As soon as a quotation outputs " { $link f } ", evaluation stops and subsequent quotations are not called." } ;

HELP: ||
{ $values { "quots" "a sequence of quotations with stack effect " { $snippet "( ... -- ... ? )" } } }
{ $description "Calls each quotation in turn; outputs " { $link t } " if one of the quotations output " { $link t } ", otherwise outputs " { $link f } ". As soon as a quotation outputs " { $link t } ", evaluation stops and subsequent quotations are not called." } ;

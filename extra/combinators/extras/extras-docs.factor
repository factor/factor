USING: combinators help.markup help.syntax kernel quotations ;

IN: combinators.extras

HELP: once
{ $values { "quot" "a quotation" } }
{ $description "Calls a quotation one time." } ;

HELP: twice
{ $values { "quot" "a quotation" } }
{ $description "Calls a quotation two times." }
{ $examples
    "The following two lines are equivalent:"
    { $code "[ q ] twice" "q q" }
} ;

HELP: thrice
{ $values { "quot" "a quotation" } }
{ $description "Calls a quotation three times." }
{ $examples
    "The following two lines are equivalent:"
    { $code "[ q ] thrice" "q q q" }
} ;

HELP: forever
{ $values { "quot" "a quotation" } }
{ $description "Calls a quotation in an endless loop." }
{ $examples
    "The following two lines are equivalent:"
    { $code "[ q ] forever" "[ t ] [ q ] while" }
} ;

HELP: cond-case
{ $values { "assoc" "a sequence of quotation pairs and an optional quotation" } }
{ $description
    "Similar to " { $link case } ", this evaluates an " { $snippet "obj" } " according to the first quotation in each pair. If any quotation returns true, calls the second quotation without " { $snippet "obj" } " on the stack."
    $nl
    "If there is no quotation that returns true, the default case is taken. If the last element of " { $snippet "assoc" } " is a quotation, the quotation is called with " { $snippet "obj" } " on the stack. Otherwise, a " { $link no-cond } " error is raised."
}
{ $examples
    { $example
        "USING: combinators.extras io kernel math ;"
        "0 {"
        "    { [ 0 > ] [ \"positive\" ] }"
        "    { [ 0 < ] [ \"negative\" ] }"
        "    [ drop \"zero\" ]"
        "} cond-case print"
        "zero"
    }
} ;

HELP: cleave-array
{ $values { "quots" "a sequence of quotations" } }
{ $description "Like " { $link cleave } ", but wraps the output in an array." } ;

HELP: 4bi
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( w x y z -- ... ) } } { "q" { $quotation ( w x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to the four input values, then applies " { $snippet "q" } " to the four input values." } ;

HELP: 4tri
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( w x y z -- ... ) } } { "q" { $quotation ( w x y z -- ... ) } } { "r" { $quotation ( w x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to the four input values, then applies " { $snippet "q" } " to the four input values, and finally applies " { $snippet "r" } " to the four input values." } ;

HELP: quad
{ $values { "x" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( x -- ... ) } } { "r" { $quotation ( x -- ... ) } } { "s" { $quotation ( x -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "x" } ", then applies " { $snippet "q" } " to " { $snippet "x" } ", then applies " { $snippet "r" } " to " { $snippet "x" } ", and finally applies " { $snippet "s" } " to " { $snippet "x" } "." } ;

HELP: 2quad
{ $values { "x" object } { "y" object } { "p" { $quotation ( x y -- ... ) } } { "q" { $quotation ( x y -- ... ) } } { "r" { $quotation ( x y -- ... ) } } { "s" { $quotation ( x y -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to the two input values, then applies " { $snippet "q" } " to the two input values, then applies " { $snippet "r" } " to the two input values, and finally applies " { $snippet "s" } " to the two input values." } ;

HELP: 3quad
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation ( x y z -- ... ) } } { "q" { $quotation ( x y z -- ... ) } } { "r" { $quotation ( x y z -- ... ) } } { "s" { $quotation ( x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to the three input values, then applies " { $snippet "q" } " to the three input values, then applies " { $snippet "r" } " to the three input values, and finally applies " { $snippet "s" } " to the three input values." } ;

HELP: 4quad
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( w x y z -- ... ) } } { "q" { $quotation ( w x y z -- ... ) } } { "r" { $quotation ( w x y z -- ... ) } } { "s" { $quotation ( w x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to the four input values, then applies " { $snippet "q" } " to the four input values, then applies " { $snippet "r" } " to the four input values, and finally applies " { $snippet "s" } " to the four input values." } ;

HELP: 3bi*
{ $values { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( u v w -- ... ) } } { "q" { $quotation ( x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "u" } ", " { $snippet "v" } " and " { $snippet "w" } ", then applies " { $snippet "q" } " to " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 4bi*
{ $values { "s" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( s t u v -- ... ) } } { "q" { $quotation ( w x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "s" } ", " { $snippet "t" } ", " { $snippet "u" } " and " { $snippet "v" } ", then applies " { $snippet "q" } " to " { $snippet "w" } ", " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 3tri*
{ $values { "o" object } { "s" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( o s t -- ... ) } } { "q" { $quotation ( u v w -- ... ) } } { "r" { $quotation ( x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } to { $snippet "o" } ", " { $snippet "s" } " and " { $snippet "t" } ", then applies " { $snippet "q" } " to " { $snippet "u" } ", " { $snippet "v" } " and " { $snippet "w" } ", and finally applies " { $snippet "r" } " to " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 4tri*
{ $values { "l" object } { "m" object } { "n" object } { "o" object } { "s" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( l m n o -- ... ) } } { "q" { $quotation ( s t u v -- ... ) } } { "r" { $quotation ( w x y z -- ... ) } } }
{ $description "Applies" { $snippet "p" } " to " { $snippet "l" } ", " { $snippet "m" } ", " { $snippet "n" } " and " { $snippet "o" } ", then applies q to " { $snippet "s" } ", " { $snippet "t" } ", " { $snippet "u" } ", " { $snippet "v" } ", and finally applies " { $snippet "r" } " to " { $snippet "w" } ", " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: quad*
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( x -- ... ) } } { "r" { $quotation ( x -- ... ) } } { "s" { $quotation ( x -- ... ) } } }
{ $description "Applies" { $snippet "p" } " to " { $snippet "w" } ", then applies " { $snippet "q" } " to " { $snippet "x" } ", then applies " { $snippet "r" } " to " { $snippet "y" } ", and finally applies " { $snippet "s" } " to " { $snippet "z" } "." } ;

HELP: 2quad*
{ $values { "o" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( s t  -- ... ) } } { "q" { $quotation ( u v -- ... ) } } { "r" { $quotation ( w x -- ... ) } } { "s" { $quotation ( y z -- ... ) } } }
{ $description "Applies" { $snippet "p" } " to " { $snippet "s" } " and " { $snippet "t" } ", then applies " { $snippet "q" } " to " { $snippet "u" } " and " { $snippet "v" } ", then applies" { $snippet "r" } " to " { $snippet "w" } " and " { $snippet "x" } ", and finally applies " { $snippet "s" } " to " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 3quad*
{ $values { "k" object } { "l" object } { "m" object } { "n" object } { "o" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( o p q  -- ... ) } } { "q" { $quotation ( r s t -- ... ) } } { "r" { $quotation ( u v w -- ... ) } } { "s" { $quotation ( x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "k" } ", " { $snippet "l" } " and " { $snippet "m" } ", then applies " { $snippet "q" } " to " { $snippet "n" } ", " { $snippet "o" } " and " { $snippet "t" } ", then applies " { $snippet "r" } " to " { $snippet "u" } ", " { $snippet "v" } " and " { $snippet "w" } ", and finally applies " { $snippet "s" } " to " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 4quad*
{ $values { "g" object } { "h" object } { "i" object } { "j" object } { "k" object } { "l" object } { "m" object } { "n" object } { "o" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( k l m n  -- ... ) } } { "q" { $quotation ( o p q r -- ... ) } } { "r" { $quotation ( s t u v -- ... ) } } { "s" { $quotation ( w x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "g" } ", " { $snippet "h" } ", " { $snippet "i" } " and " { $snippet "j" } ", then applies " { $snippet "q" } " to " { $snippet "k" } ", " { $snippet "l" } ", " { $snippet "m" } " and " { $snippet "n" } ", then applies " { $snippet "r" } " to " { $snippet "o" } ", " { $snippet "t" } ", " { $snippet "u" } " and " { $snippet "v" } ", and finally applies " { $snippet "s" } " to " { $snippet "w" } ", " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 3bi@
{ $values { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 obj3 -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "u" } ", " { $snippet "v" } " and " { $snippet "w" } ", and then to " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 4bi@
{ $values { "s" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj 2 obj3 obj4 -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "s" } ", " { $snippet "t" } ", " { $snippet "u" } " and " { $snippet "v" } ", and then to " { $snippet "w" } ", " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 3tri@
{ $values { "r" object } { "s" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 obj3  -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "r" } ", " { $snippet "s" } " and " { $snippet "t" } ", then to " { $snippet "u" } ", " { $snippet "v" } " and " { $snippet "w" } ", and then to " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 4tri@
{ $values { "o" object } { "p" object } { "q" object } { "r" object } { "s" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 obj3 obj4 -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "o" } ", " { $snippet "p" } ", " { $snippet "q" } ", " { $snippet "r" } ", then to " { $snippet "s" } ", " { $snippet "t" } ", " { $snippet "u" } " and " { $snippet "v" } ", and finally to " { $snippet "w" } ", " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: quad@
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "w" } ", then to " { $snippet "x" } ", then to " { $snippet "y" } ", and finally to " { $snippet "z" } "." } ;

HELP: 2quad@
{ $values { "s" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "s" } " and " { $snippet "t" } ", then to " { $snippet "u" } " and " { $snippet "v" } ", then to " { $snippet "w" } " and " { $snippet "x" } ", and finally to " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 3quad@
{ $values { "o" object } { "p" object } { "q" object } { "r" object } { "s" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 obj3 -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "o" } ", " { $snippet "p" } " and " { $snippet "q" } ", then to " { $snippet "r" } ", " { $snippet "s" } " and " { $snippet "t" } ", then to " { $snippet "u" } ", " { $snippet "v" } " and " { $snippet "w" } ", and finally to " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: 4quad@
{ $values { "k" object } { "l" object } { "m" object } { "n" object } { "o" object } { "p" object } { "q" object } { "r" object } { "s" object } { "t" object } { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 obj3 obj4 -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "k" } ", " { $snippet "l" } ", " { $snippet "m" } " and " { $snippet "n" } ", then to " { $snippet "o" } ", " { $snippet "p" } ", " { $snippet "q" } " and " { $snippet "r" } ", then to " { $snippet "s" } ", " { $snippet "t" } ", " { $snippet "u" } " and " { $snippet "v" } ", and finally to " { $snippet "w" } ", " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: quad-curry
{ $values { "x" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( x -- ... ) } } { "r" { $quotation ( x -- ... ) } } { "s" { $quotation ( x -- ... ) } } { "p'" { $snippet "[ x p ] " } } { "q'" { $snippet "[ x q ] " } } { "r'" { $snippet "[ x r ] " } } { "s'" { $snippet "[ x s ] " } } }
{ $description "Partially applies " { $snippet "p" } ", " { $snippet "q" } ", " { $snippet "r" } " and " { $snippet "s" } " to " { $snippet "x" } "." } ;

HELP: quad-curry*
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( x -- ... ) } } { "r" { $quotation ( x -- ... ) } } { "s" { $quotation ( x -- ... ) } } { "p'" { $snippet "[ w p ] " } } { "q'" { $snippet "[ x q ] " } } { "r'" { $snippet "[ y r ] " } } { "s'" { $snippet "[ z s ] " } } }
{ $description "Partially applies " { $snippet "p" } " to " { $snippet "w" } ", " { $snippet "q" } " to " { $snippet "x" } ", " { $snippet "r" } " to " { $snippet "y" } ", and " { $snippet "s" } " to " { $snippet "z" } "." } ;

HELP: quad-curry@
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "q" { $quotation ( x -- ... ) } } { "p'" { $snippet "[ w q ] " } } { "q'" { $snippet "[ x q ] " } } { "r'" { $snippet "[ y q ] " } } { "s'" { $snippet "[ z q ] " } } }
{ $description "Partially applies" { $snippet "q" } " to " { $snippet "w" } ", " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." } ;

HELP: smart-plox
{ $values { "true" { $quotation ( ... -- x ) } } }
{ $description "Applies the quotation if none of the values consumed by the quotation are " { $link f } ", otherwise puts " { $link f } "on the stack." }
;

HELP: loop1
{ $values { "quot" { $quotation ( ..a -- ..a obj ? ) } } { "obj" object } }
{ $description "Similar to " { $link loop } ". Calls the the quotation repeatedly until it outputs " { $link f } ". While it does so, discards " { $snippet "obj" } ". When the loop finishes, leaves" { $snippet "obj" } "on the stack." } ;

HELP: keep-1up
{ $values { "quot" quotation } }
{ $description "Calls a quotation with a value on the stack, restoring the value under the topmost item on the stack." } ;

HELP: keep-2up
{ $values { "quot" quotation } }
{ $description "Calls a quotation with a value on the stack, restoring the value under the two topmost items on the stack." } ;

HELP: keep-3up
{ $values { "quot" quotation } }
{ $description "Calls a quotation with a value on the stack, restoring the value under the three topmost items on the stack." } ;

HELP: 2keep-1up
{ $values { "quot" quotation } }
{ $description "Calls a quotation with two values on the stack, restoring the values under the topmost item on the stack." } ;

HELP: 2keep-2up
{ $values { "quot" quotation } }
{ $description "Calls a quotation with two values on the stack, restoring the values under the two topmost items on the stack." } ;

HELP: 2keep-3up
{ $values { "quot" quotation } }
{ $description "Calls a quotation with two values on the stack, restoring the values under the three topmost items on the stack." } ;

HELP: 3keep-1up
{ $values { "quot" quotation } }
{ $description "Calls a quotation with three values on the stack, restoring the values under the topmost item on the stack." } ;

HELP: 3keep-2up
{ $values { "quot" quotation } }
{ $description "Calls a quotation with three values on the stack, restoring the values under the two topmost items on the stack." } ;

HELP: 3keep-3up
{ $values { "quot" quotation } }
{ $description "Calls a quotation with three values on the stack, restoring the values under the three topmost items on the stack." } ;

HELP: dip-1up
{ $values { "d" object } { "quot" { $quotation ( ..a -- ..b o ) } } { "o" object } }
{ $description "Like " { $link dip } ", but moves the last value left on the stack by the quotation to the top of the stack." } ;

HELP: dip-2up
{ $values { "d" object } { "quot" { $quotation ( ..a -- ..b o1 o2 ) } } { "o1" object } { "o2" object } }
{ $description "Like " { $link dip } ", but moves the last two values left on the stack by the quotation to the top of the stack." } ;

HELP: 2dip-1up
{ $values { "d" object } { "quot" { $quotation ( ..a -- ..b o ) } } { "o" object } }
{ $description "Like " { $link 2dip } ", but moves the last value left on the stack by the quotation to the top of the stack." } ;

HELP: 2dip-2up
{ $values { "d" object } { "quot" { $quotation ( ..a -- ..b o1 o2 ) } } { "o1" object } { "o2" object } }
{ $description "Like " { $link 2dip } ", but moves the last two values left on the stack by the quotation to the top of the stack." } ;

HELP: 3dip-1up
{ $values { "d" object } { "quot" { $quotation ( ..a -- ..b o ) } } { "o" object } }
{ $description "Like " { $link 3dip } ", but moves the last value left on the stack by the quotation to the top of the stack." } ;

HELP: 3dip-2up
{ $values { "d" object } { "quot" { $quotation ( ..a -- ..b o1 o2 ) } } { "o1" object } { "o2" object } }
{ $description "Like " { $link 3dip } ", but moves the last two values left on the stack by the quotation to the top of the stack." } ;

HELP: 3dip-3up
{ $values { "d" object } { "quot" { $quotation ( ..a -- ..b o1 o2 ) } } { "o1" object } { "o2" object } }
{ $description "Like " { $link 3dip } ", but moves the last three values left on the stack by the quotation to the top of the stack." } ;

HELP: 2craft-1up
{ $values { "quot1" { $quotation ( ..a -- ..b o1 ) } } { "quot2" { $quotation ( ..b -- ..c o2 ) } } { "o1" object } { "o2" object } }
{ $description "Applies " { $snippet "quot1" } "to the values on the stack and saves the last value left by the quotation on the stack. Then applies " { $snippet "quot2" } "to the rest of the values left on the stack by " { $snippet "quot1" } " and saves the last value left by the quotation on the stack. Finally the word puts the saved values on the stack." } ;

HELP: 3craft-1up
{ $values { "quot1" { $quotation ( ..a -- ..b o1 ) } } { "quot2" { $quotation ( ..b -- ..c o2 ) } } { "quot3" { $quotation ( ..c -- ..d o1 ) } } { "o1" object } { "o2" object } { "o3" object } }
{ $description "A version of " { $link 2craft-1up } "that crafts 3 values." } ;

HELP: 4craft-1up
{ $values { "quot1" { $quotation ( ..a -- ..b o1 ) } } { "quot2" { $quotation ( ..b -- ..c o2 ) } } { "quot3" { $quotation ( ..c -- ..d o1 ) } } { "quot4" { $quotation ( ..d -- ..e o1 ) } } { "o1" object } { "o2" object } { "o3" object } { "o4" object } }
{ $description "A version of " { $link 2craft-1up } "that crafts 4 values." } ;

HELP: 3and
{ $values { "a" "a generalized boolean" } { "b" "a generalized boolean" } { "c" "a generalized boolean" } }
{ $description "Like " { $link and } ", but takes 3 values." } ;

HELP: 4and
{ $values { "a" "a generalized boolean" } { "b" "a generalized boolean" } { "c" "a generalized boolean" } { "d" "a generalized boolean" } }
{ $description "Like " { $link and } ", but takes 4 values." } ;

HELP: 3or
{ $values { "a" "a generalized boolean" } { "b" "a generalized boolean" } { "c" "a generalized boolean" } }
{ $description "Like " { $link or } ", but takes 3 values." } ;

HELP: 4or
{ $values { "a" "a generalized boolean" } { "b" "a generalized boolean" } { "c" "a generalized boolean" } { "d" "a generalized boolean" } }
{ $description "Like " { $link or } ", but takes 4 values." } ;

HELP: keep-under
{ $values { "quot" quotation } }
{ $description "Calls a quotation with a value on the stack, restoring the value below the outputs when the quotation returns." } ;

HELP: 2keep-under
{ $values { "quot" quotation } }
{ $description "Calls a quotation with two values on the stack, restoring the values below the outputs when the quotation returns." } ;

HELP: 3keep-under
{ $values { "quot" quotation } }
{ $description "Calls a quotation with three values on the stack, restoring the values below the outputs when the quotation returns." } ;

HELP: 4keep-under
{ $values { "quot" quotation } }
{ $description "Calls a quotation with four values on the stack, restoring the values below the outputs when the quotation returns." } ;

ARTICLE: "combinators.extras" "Extra combinators"
"Call a quotation one, two or three times:" { $subsections once twice thrice }
"Endless loops:" { $subsections forever }
"An easier " { $link cond } " combinator:" { $subsections cond-case }
"Cleave into an array:" { $subsections cleave-array }
"More dataflow combinators:" { $subsections 4bi 3bi* 4bi* 3bi@ 4bi@ } { $subsections 4tri 3tri* 4tri* 3tri@ 4tri@ } { $subsections quad 2quad 3quad 4quad quad* 2quad* 3quad* 4quad* quad@ 2quad@ 3quad@ 4quad@ } { $subsections quad-curry quad-curry* quad-curry@ }
"Stack permuting versions of " { $link keep } " and " { $link dip } ":" { $subsections keep-1up keep-2up keep-3up 2keep-1up 2keep-2up 2keep-3up 3keep-1up 3keep-2up 3keep-3up } { $subsections keep-under 2keep-under 3keep-under 4keep-under } { $subsections dip-1up dip-2up 2dip-1up 2dip-2up 3dip-1up 3dip-2up 3dip-3up } { $subsections 2craft-1up 3craft-1up 4craft-1up }
"3- and 4-element versions of " { $link and } " and " { $link or } ":" { $subsections 3and 4and 3or 4or } ;

ABOUT: "combinators.extras"

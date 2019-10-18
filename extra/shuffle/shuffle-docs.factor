! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup kernel sequences shuffle ;

HELP: ndip
{ $values { "quot" "a quotation" } { "n" "a number" } }
{ $description "A generalisation of " { $link dip } " that can work " 
"for any stack depth. The quotation will be called with a stack that "
"has 'n' items removed first. The 'n' items are then put back on the "
"stack. The quotation can consume and produce any number of items."
} 
{ $examples
  { $example "USE: shuffle" "1 2 [ dup ] 1 ndip .s" "1\n1\n2" }
  { $example "USE: shuffle" "1 2 3 [ drop ] 2 ndip .s" "2\n3" }
}
{ $see-also dip dipd } ;

HELP: npick
{ $values { "n" "a number" } }
{ $description "A generalisation of " { $link dup } ", " 
{ $link over } " and " { $link pick } " that can work " 
"for any stack depth. The nth item down the stack will be copied and "
"placed on the top of the stack."
} 
{ $examples
  { $example "USE: shuffle" "1 2 3 4 4 npick .s" "1\n2\n3\n4\n1" }
}
{ $see-also dup over pick } ;

HELP: ndup
{ $values { "n" "a number" } }
{ $description "A generalisation of " { $link dup } ", " 
{ $link 2dup } " and " { $link 3dup } " that can work " 
"for any number of items. The n topmost items on the stack will be copied and "
"placed on the top of the stack."
} 
{ $examples
  { $example "USE: shuffle" "1 2 3 4 4 ndup .s" "1\n2\n3\n4\n1\n2\n3\n4" }
}
{ $see-also dup 2dup 3dup } ;

HELP: nnip
{ $values { "n" "a number" } }
{ $description "A generalisation of " { $link nip } " and " { $link 2nip } 
" that can work " 
"for any number of items."
} 
{ $examples
  { $example "USE: shuffle" "1 2 3 4 3 nnip .s" "4" }
}
{ $see-also nip 2nip } ;

HELP: ndrop
{ $values { "n" "a number" } }
{ $description "A generalisation of " { $link drop } 
" that can work " 
"for any number of items."
} 
{ $examples
  { $example "USE: shuffle" "1 2 3 4 3 ndrop .s" "1" }
}
{ $see-also drop 2drop 3drop } ;

HELP: nrot
{ $values { "n" "a number" } }
{ $description "A generalisation of " { $link rot } " that works for any "
"number of items on the stack. " 
} 
{ $examples
  { $example "USE: shuffle" "1 2 3 4 4 nrot .s" "2\n3\n4\n1" }
}
{ $see-also rot -nrot } ;

HELP: -nrot
{ $values { "n" "a number" } }
{ $description "A generalisation of " { $link -rot } " that works for any "
"number of items on the stack. " 
} 
{ $examples
  { $example "USE: shuffle" "1 2 3 4 4 -nrot .s" "4\n1\n2\n3" }
}
{ $see-also rot nrot } ;

HELP: nslip
{ $values { "n" "a number" } }
{ $description "A generalisation of " { $link slip } " that can work " 
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"removed from the stack, the quotation called, and the items restored."
} 
{ $examples
  { $example "USE: shuffle" "[ 99 ] 1 2 3 4 5 5 nslip .s" "99\n1\n2\n3\n4\n5" }
}
{ $see-also slip nkeep } ;

HELP: nkeep
{ $values { "quot" "a quotation" } { "n" "a number" } }
{ $description "A generalisation of " { $link keep } " that can work " 
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"saved, the quotation called, and the items restored."
} 
{ $examples
  { $example "USE: shuffle" "1 2 3 4 5 [ drop drop drop drop drop 99 ] 5 nkeep .s" "99\n1\n2\n3\n4\n5" }
}
{ $see-also keep nslip } ;

HELP: map-withn
{ $values { "seq" "a sequence" } { "quot" "a quotation" } { "n" "a number" } { "newseq" "a sequence" } }
{ $description "A generalisation of " { $link map } ". The first " { $snippet "n" } " items after the quotation will be "
"passed to the quotation given to map-withn for each element in the sequence."
} 
{ $examples
  { $example "USE: shuffle" "1 2 3 4 { 6 7 8 9 10 } [ + + + + ] 4 map-withn .s" "{ 16 17 18 19 20 }" }
}
{ $see-also each-withn } ;

HELP: each-withn
{ $values { "seq" "a sequence" } { "quot" "a quotation" } { "n" "a number" } }
{ $description "A generalisation of " { $link each } ". The first " { $snippet "n" } " items after the quotation will be "
"passed to the quotation given to each-withn for each element in the sequence."
} 
{ $see-also map-withn } ;

ARTICLE: { "shuffle" "overview" } "Extra shuffle words"
"A number of stack shuffling words for those rare times when you "
"need to deal with tricky stack situations and can't refactor the "
"code to work around it." 
{ $subsection ndip } 
{ $subsection ndup } 
{ $subsection npick } 
{ $subsection nrot } 
{ $subsection -nrot } 
{ $subsection nnip } 
{ $subsection ndrop } 
{ $subsection nslip } 
{ $subsection nkeep } 
{ $subsection ncurry }
{ $subsection ncurry* }
{ $subsection napply }
{ $subsection map-withn } 
{ $subsection each-withn } ;

IN: shuffle
ABOUT: { "shuffle" "overview" }
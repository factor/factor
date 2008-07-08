! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup kernel sequences quotations
math ;
IN: generalizations

HELP: npick
{ $values { "n" integer } }
{ $description "A generalization of " { $link dup } ", "
{ $link over } " and " { $link pick } " that can work "
"for any stack depth. The nth item down the stack will be copied and "
"placed on the top of the stack."
}
{ $examples
  { $example "USING: prettyprint generalizations ;" "1 2 3 4 4 npick .s" "1\n2\n3\n4\n1" }
}
{ $see-also dup over pick } ;

HELP: ndup
{ $values { "n" integer } }
{ $description "A generalization of " { $link dup } ", "
{ $link 2dup } " and " { $link 3dup } " that can work "
"for any number of items. The n topmost items on the stack will be copied and "
"placed on the top of the stack."
}
{ $examples
  { $example "USING: prettyprint generalizations ;" "1 2 3 4 4 ndup .s" "1\n2\n3\n4\n1\n2\n3\n4" }
}
{ $see-also dup 2dup 3dup } ;

HELP: nnip
{ $values { "n" integer } }
{ $description "A generalization of " { $link nip } " and " { $link 2nip }
" that can work "
"for any number of items."
}
{ $examples
  { $example "USING: prettyprint generalizations ;" "1 2 3 4 3 nnip .s" "4" }
}
{ $see-also nip 2nip } ;

HELP: ndrop
{ $values { "n" integer } }
{ $description "A generalization of " { $link drop }
" that can work "
"for any number of items."
}
{ $examples
  { $example "USING: prettyprint generalizations ;" "1 2 3 4 3 ndrop .s" "1" }
}
{ $see-also drop 2drop 3drop } ;

HELP: nrot
{ $values { "n" integer } }
{ $description "A generalization of " { $link rot } " that works for any "
"number of items on the stack. "
}
{ $examples
  { $example "USING: prettyprint generalizations ;" "1 2 3 4 4 nrot .s" "2\n3\n4\n1" }
}
{ $see-also rot -nrot } ;

HELP: -nrot
{ $values { "n" integer } }
{ $description "A generalization of " { $link -rot } " that works for any "
"number of items on the stack. "
}
{ $examples
  { $example "USING: prettyprint generalizations ;" "1 2 3 4 4 -nrot .s" "4\n1\n2\n3" }
}
{ $see-also rot nrot } ;

HELP: nrev
{ $values { "n" integer } }
{ $description "A generalization of " { $link spin } " that reverses any number of items at the top of the stack."
}
{ $examples
  { $example "USING: prettyprint generalizations ;" "1 2 3 4 4 nrev .s" "4\n3\n2\n1" }
}
{ $see-also rot nrot } ;

HELP: ndip
{ $values { "quot" quotation } { "n" number } }
{ $description "A generalization of " { $link dip } " that can work " 
"for any stack depth. The quotation will be called with a stack that "
"has 'n' items removed first. The 'n' items are then put back on the "
"stack. The quotation can consume and produce any number of items."
} 
{ $examples
  { $example "USING: generalizations kernel prettyprint ;" "1 2 [ dup ] 1 ndip .s" "1\n1\n2" }
  { $example "USING: generalizations kernel prettyprint ;" "1 2 3 [ drop ] 2 ndip .s" "2\n3" }
}
{ $see-also dip 2dip } ;

HELP: nslip
{ $values { "n" number } }
{ $description "A generalization of " { $link slip } " that can work " 
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"removed from the stack, the quotation called, and the items restored."
} 
{ $examples
  { $example "USING: generalizations prettyprint ;" "[ 99 ] 1 2 3 4 5 5 nslip .s" "99\n1\n2\n3\n4\n5" }
}
{ $see-also slip nkeep } ;

HELP: nkeep
{ $values { "quot" quotation } { "n" number } }
{ $description "A generalization of " { $link keep } " that can work " 
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"saved, the quotation called, and the items restored."
} 
{ $examples
  { $example "USING: generalizations kernel prettyprint ;" "1 2 3 4 5 [ drop drop drop drop drop 99 ] 5 nkeep .s" "99\n1\n2\n3\n4\n5" }
}
{ $see-also keep nslip } ;

ARTICLE: "generalizations" "Generalized shuffle words and combinators"
"A number of stack shuffling words and combinators for use in "
"macros where the arity of the input quotations depends on an "
"input parameter."
{ $subsection narray }
{ $subsection ndup }
{ $subsection npick }
{ $subsection nrot }
{ $subsection -nrot }
{ $subsection nnip }
{ $subsection ndrop }
{ $subsection nrev }
{ $subsection ndip }
{ $subsection nslip }
{ $subsection nkeep }
{ $subsection ncurry } 
{ $subsection nwith } 
{ $subsection napply } ;

ABOUT: "generalizations"

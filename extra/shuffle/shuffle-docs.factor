! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup kernel sequences shuffle ;

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

ARTICLE: { "shuffle" "overview" } "Extra shuffle words"
"A number of stack shuffling words for those rare times when you "
"need to deal with tricky stack situations and can't refactor the "
"code to work around it." 
{ $subsection ndup } 
{ $subsection npick } 
{ $subsection nrot } 
{ $subsection -nrot } 
{ $subsection nnip } 
{ $subsection ndrop }  ;

IN: shuffle
ABOUT: { "shuffle" "overview" }
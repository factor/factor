USING: help.syntax help.markup kernel sequences quotations
math arrays combinators ;
IN: generalizations

HELP: nsequence
{ $values { "n" integer } { "seq" "an exemplar" } }
{ $description "A generalization of " { $link 2sequence } ", "
{ $link 3sequence } ", and " { $link 4sequence } " "
"that constructs a sequence from the top " { $snippet "n" } " elements of the stack."
}
{ $examples
    { $example "USING: generalizations prettyprint ;" "CHAR: f CHAR: i CHAR: s CHAR: h 4 \"\" nsequence ." "\"fish\"" }
} ;

HELP: narray
{ $values { "n" integer } }
{ $description "A generalization of " { $link 1array } ", "
{ $link 2array } ", " { $link 3array } " and " { $link 4array } " "
"that constructs an array from the top " { $snippet "n" } " elements of the stack."
}
{ $examples
    "Some core words expressed in terms of " { $link narray } ":"
    { $table
        { { $link 1array } { $snippet "1 narray" } }
        { { $link 2array } { $snippet "2 narray" } }
        { { $link 3array } { $snippet "3 narray" } }
        { { $link 4array } { $snippet "4 narray" } }
    }
} ;

{ nsequence narray } related-words

HELP: nsum
{ $values { "n" integer } }
{ $description "Adds the top " { $snippet "n" } " stack values." } ;

HELP: firstn
{ $values { "n" integer } }
{ $description "A generalization of " { $link first } ", "
{ $link first2 } ", " { $link first3 } " and " { $link first4 } " "
"that pushes the first " { $snippet "n" } " elements of a sequence on the stack."
}
{ $examples
    "Some core words expressed in terms of " { $link firstn } ":"
    { $table
        { { $link first } { $snippet "1 firstn" } }
        { { $link first2 } { $snippet "2 firstn" } }
        { { $link first3 } { $snippet "3 firstn" } }
        { { $link first4 } { $snippet "4 firstn" } }
    }
} ;

HELP: npick
{ $values { "n" integer } }
{ $description "A generalization of " { $link dup } ", "
{ $link over } " and " { $link pick } " that can work "
"for any stack depth. The nth item down the stack will be copied and "
"placed on the top of the stack."
}
{ $examples
  { $example "USING: kernel prettyprint generalizations ;" "1 2 3 4 4 npick 5 narray ." "{ 1 2 3 4 1 }" }
  "Some core words expressed in terms of " { $link npick } ":"
    { $table
        { { $link dup } { $snippet "1 npick" } }
        { { $link over } { $snippet "2 npick" } }
        { { $link pick } { $snippet "3 npick" } }
    }
} ;

HELP: ndup
{ $values { "n" integer } }
{ $description "A generalization of " { $link dup } ", "
{ $link 2dup } " and " { $link 3dup } " that can work "
"for any number of items. The n topmost items on the stack will be copied and "
"placed on the top of the stack."
}
{ $examples
  { $example "USING: prettyprint generalizations kernel ;" "1 2 3 4 4 ndup 8 narray ." "{ 1 2 3 4 1 2 3 4 }" }
  "Some core words expressed in terms of " { $link ndup } ":"
    { $table
        { { $link dup } { $snippet "1 ndup" } }
        { { $link 2dup } { $snippet "2 ndup" } }
        { { $link 3dup } { $snippet "3 ndup" } }
    }
} ;

HELP: nnip
{ $values { "n" integer } }
{ $description "A generalization of " { $link nip } " and " { $link 2nip }
" that can work "
"for any number of items."
}
{ $examples
  { $example "USING: prettyprint generalizations kernel ;" "1 2 3 4 3 nnip ." "4" }
  "Some core words expressed in terms of " { $link nnip } ":"
    { $table
        { { $link nip } { $snippet "1 nnip" } }
        { { $link 2nip } { $snippet "2 nnip" } }
    }
} ;

HELP: ndrop
{ $values { "n" integer } }
{ $description "A generalization of " { $link drop }
" that can work "
"for any number of items."
}
{ $examples
  { $example "USING: prettyprint generalizations kernel ;" "1 2 3 4 3 ndrop ." "1" }
  "Some core words expressed in terms of " { $link ndrop } ":"
    { $table
        { { $link drop } { $snippet "1 ndrop" } }
        { { $link 2drop } { $snippet "2 ndrop" } }
        { { $link 3drop } { $snippet "3 ndrop" } }
    }
} ;

HELP: nrot
{ $values { "n" integer } }
{ $description "A generalization of " { $link rot } " that works for any "
"number of items on the stack. "
}
{ $examples
  { $example "USING: arrays generalizations kernel prettyprint ;" "1 2 3 4 4 nrot 4array ." "{ 2 3 4 1 }" }
  "Some core words expressed in terms of " { $link nrot } ":"
    { $table
        { { $link swap } { $snippet "1 nrot" } }
        { { $link rot } { $snippet "2 nrot" } }
    }
} ;

HELP: -nrot
{ $values { "n" integer } }
{ $description "A generalization of " { $link -rot } " that works for any "
"number of items on the stack. "
}
{ $examples
  { $example "USING: arrays generalizations kernel prettyprint ;" "1 2 3 4 4 -nrot 4array ." "{ 4 1 2 3 }" }
  "Some core words expressed in terms of " { $link -nrot } ":"
    { $table
        { { $link swap } { $snippet "1 -nrot" } }
        { { $link -rot } { $snippet "2 -nrot" } }
    }
} ;

HELP: ndip
{ $values { "quot" quotation } { "n" integer } }
{ $description "A generalization of " { $link dip } " that can work " 
"for any stack depth. The quotation will be called with a stack that "
"has 'n' items removed first. The 'n' items are then put back on the "
"stack. The quotation can consume and produce any number of items."
} 
{ $examples
  { $example "USING: arrays generalizations kernel prettyprint ;" "1 2 [ dup ] 1 ndip 3array ." "{ 1 1 2 }" }
  { $example "USING: arrays generalizations kernel prettyprint ;" "1 2 3 [ drop ] 2 ndip 2array ." "{ 2 3 }" }
  "Some core words expressed in terms of " { $link ndip } ":"
    { $table
        { { $link dip } { $snippet "1 ndip" } }
        { { $link 2dip } { $snippet "2 ndip" } }
        { { $link 3dip } { $snippet "3 ndip" } }
    }
} ;

HELP: nkeep
{ $values { "quot" quotation } { "n" integer } }
{ $description "A generalization of " { $link keep } " that can work " 
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"saved, the quotation called, and the items restored."
} 
{ $examples
  { $example "USING: generalizations kernel prettyprint ;" "1 2 3 4 5 [ drop drop drop drop drop 99 ] 5 nkeep 6 narray ." "{ 99 1 2 3 4 5 }" }
  "Some core words expressed in terms of " { $link nkeep } ":"
    { $table
        { { $link keep } { $snippet "1 nkeep" } }
        { { $link 2keep } { $snippet "2 nkeep" } }
        { { $link 3keep } { $snippet "3 nkeep" } }
    }
} ;

HELP: ncurry
{ $values { "quot" quotation } { "n" integer } }
{ $description "A generalization of " { $link curry } " that can work for any stack depth."
} 
{ $examples
  "Some core words expressed in terms of " { $link ncurry } ":"
    { $table
        { { $link curry } { $snippet "1 ncurry" } }
        { { $link 2curry } { $snippet "2 ncurry" } }
        { { $link 3curry } { $snippet "3 ncurry" } }
    }
} ;

HELP: nwith
{ $values { "quot" quotation } { "n" integer } }
{ $description "A generalization of " { $link with } " that can work for any stack depth."
} 
{ $examples
  "Some core words expressed in terms of " { $link nwith } ":"
    { $table
        { { $link with } { $snippet "1 nwith" } }
    }
} ;

HELP: napply
{ $values { "quot" quotation } { "n" integer } }
{ $description "A generalization of " { $link bi@ } " and " { $link tri@ } " that can work for any stack depth."
} 
{ $examples
  "Some core words expressed in terms of " { $link napply } ":"
    { $table
        { { $link call } { $snippet "1 napply" } }
        { { $link bi@ } { $snippet "2 napply" } }
        { { $link tri@ } { $snippet "3 napply" } }
    }
} ;

HELP: ncleave
{ $values { "quots" "a sequence of quotations" } { "n" integer } }
{ $description "A generalization of " { $link cleave } " and " { $link 2cleave } " that can work for any quotation arity."
} 
{ $examples
  "Some core words expressed in terms of " { $link ncleave } ":"
    { $table
        { { $link cleave } { $snippet "1 ncleave" } }
        { { $link 2cleave } { $snippet "2 ncleave" } }
    }
} ;

HELP: nspread
{ $values { "quots" "a sequence of quotations" } { "n" integer } }
{ $description "A generalization of " { $link spread } " that can work for any quotation arity."
} ;

HELP: mnswap
{ $values { "m" integer } { "n" integer } }
{ $description "Swaps the top " { $snippet "m" } " stack elements with the " { $snippet "n" } " elements directly underneath." }
{ $examples
  "Some core words expressed in terms of " { $link mnswap } ":"
    { $table
        { { $link swap } { $snippet "1 1 mnswap" } }
        { { $link rot } { $snippet "2 1 mnswap" } }
        { { $link -rot } { $snippet "1 2 mnswap" } }
    }
} ;

HELP: nweave
{ $values { "n" integer } }
{ $description "Copies the top " { $snippet "n" } " stack elements underneath each one of the " { $snippet "n" } " elements below." }
{ $examples
  { $example
    "USING: arrays kernel generalizations prettyprint ;"
    "\"e1\" \"e2\" \"o1\" \"o2\" 2 nweave [ 3array ] 3dip 3array 2array ."
    "{ { \"e1\" \"o1\" \"o2\" } { \"e2\" \"o1\" \"o2\" } }"
  }
} ;

HELP: n*quot
{ $values
     { "n" integer } { "quot" quotation }
     { "quot'" quotation }
}
{ $examples
    { $example "USING: generalizations prettyprint math ;"
               "3 [ + ] n*quot ."
               "[ + + + ]"
    }
}
{ $description "Construct a quotation containing the contents of " { $snippet "seq" } " repeated " { $snippet "n"} " times." } ;

HELP: nappend
{ $values
     { "n" integer }
     { "seq" sequence }
}
{ $description "Outputs a new sequence consisting of the elements of the top " { $snippet "n" } " sequences from the datastack in turn." }
{ $errors "Throws an error if any of the sequences contain elements that are not permitted in the sequence type of the first sequence." }
{ $examples
    { $example "USING: generalizations prettyprint math ;"
               "{ 1 2 } { 3 4 } { 5 6 } { 7 8 } 4 nappend ."
               "{ 1 2 3 4 5 6 7 8 }"
    }
} ;

HELP: nappend-as
{ $values
     { "n" integer } { "exemplar" sequence }
     { "seq" sequence }
}
{ $description "Outputs a new sequence of type " { $snippet "exemplar" } " consisting of the elements of the top " { $snippet "n" } " sequences from the datastack in turn." }
{ $errors "Throws an error if any of the sequences contain elements that are not permitted in the sequence type of the first sequence." }
{ $examples
    { $example "USING: generalizations prettyprint math ;"
               "{ 1 2 } { 3 4 } { 5 6 } { 7 8 } 4 V{ } nappend-as ."
               "V{ 1 2 3 4 5 6 7 8 }"
    }
} ;

{ nappend nappend-as } related-words

HELP: ntuck
{ $values
     { "n" integer }
}
{ $description "A generalization of " { $link tuck } " that can work for any stack depth. The top item will be copied and placed " { $snippet "n" } " items down on the stack." } ;

ARTICLE: "sequence-generalizations" "Generalized sequence operations"
{ $subsection narray }
{ $subsection nsequence }
{ $subsection firstn }
{ $subsection nappend }
{ $subsection nappend-as } ;

ARTICLE: "shuffle-generalizations" "Generalized shuffle words"
{ $subsection ndup }
{ $subsection npick }
{ $subsection nrot }
{ $subsection -nrot }
{ $subsection nnip }
{ $subsection ndrop }
{ $subsection ntuck }
{ $subsection mnswap }
{ $subsection nweave } ;

ARTICLE: "combinator-generalizations" "Generalized combinators"
{ $subsection ndip }
{ $subsection nkeep }
{ $subsection napply }
{ $subsection ncleave }
{ $subsection nspread } ;

ARTICLE: "other-generalizations" "Additional generalizations"
{ $subsection ncurry } 
{ $subsection nwith }
{ $subsection nsum } ;

ARTICLE: "generalizations" "Generalized shuffle words and combinators"
"The " { $vocab-link "generalizations" } " vocabulary defines a number of stack shuffling words and combinators for use in "
"macros where the arity of the input quotations depends on an "
"input parameter."
{ $subsection "sequence-generalizations" }
{ $subsection "shuffle-generalizations" }
{ $subsection "combinator-generalizations" }
{ $subsection "other-generalizations" } ;

ABOUT: "generalizations"

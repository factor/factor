USING: combinators help.markup help.syntax kernel math
quotations ;
IN: generalizations

HELP: nsum
{ $values { "n" integer } }
{ $description "Adds the top " { $snippet "n" } " stack values." } ;

HELP: npick
{ $values { "n" integer } }
{ $description "A generalization of " { $link dup } ", "
{ $link over } " and " { $link pick } " that can work "
"for any stack depth. The nth item down the stack will be copied and "
"placed on the top of the stack."
}
{ $examples
  { $example
      "USING: kernel generalizations prettyprint"
      "sequences.generalizations ;"
      ""
      "1 2 3 4 4 npick 5 narray ."
      "{ 1 2 3 4 1 }"
  }
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
  { $example
      "USING: prettyprint generalizations kernel"
      "sequences.generalizations ;"
      ""
      "1 2 3 4 4 ndup 8 narray ."
      "{ 1 2 3 4 1 2 3 4 }"
  }
  "Some core words expressed in terms of " { $link ndup } ":"
    { $table
        { { $link dup } { $snippet "1 ndup" } }
        { { $link 2dup } { $snippet "2 ndup" } }
        { { $link 3dup } { $snippet "3 ndup" } }
    }
} ;

HELP: dupn
{ $values { "n" integer } }
{ $description "Calls " { $link dup } " enough times that " { $snippet "n" } " references to the element at the top of the stack before " { $snippet "dupn" } " is called are on the top of the stack." }
{ $notes { $snippet "2 dupn" } " is equivalent to " { $link dup } ". " { $snippet "1 dupn" } " is a no-op. " { $snippet "0 dupn" } " is equivalent to " { $link drop } "." } ;

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
"number of items on the stack."
}
{ $examples
  { $example "USING: arrays generalizations kernel prettyprint ;" "1 2 3 4 4 nrot 4array ." "{ 2 3 4 1 }" }
  "Some core words expressed in terms of " { $link nrot } ":"
    { $table
        { { $link swap } { $snippet "2 nrot" } }
        { { $link rot } { $snippet "3 nrot" } }
    }
} ;

HELP: -nrot
{ $values { "n" integer } }
{ $description "A generalization of " { $link -rot } " that works for any "
"number of items on the stack."
}
{ $examples
  { $example "USING: arrays generalizations kernel prettyprint ;" "1 2 3 4 4 -nrot 4array ." "{ 4 1 2 3 }" }
  "Some core words expressed in terms of " { $link -nrot } ":"
    { $table
        { { $link swap } { $snippet "2 -nrot" } }
        { { $link -rot } { $snippet "3 -nrot" } }
    }
} ;

HELP: ndip
{ $values { "n" integer } }
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
{ $values { "n" integer } }
{ $description "A generalization of " { $link keep } " that can work "
"for any stack depth. The first " { $snippet "n" } " items after the quotation will be "
"saved, the quotation called, and the items restored."
}
{ $examples
  { $example
      "USING: generalizations kernel prettyprint"
      "sequences.generalizations ;"
      ""
      "1 2 3 4 5 [ drop drop drop drop drop 99 ] 5 nkeep 6 narray ."
      "{ 99 1 2 3 4 5 }"
  }
  "Some core words expressed in terms of " { $link nkeep } ":"
    { $table
        { { $link keep } { $snippet "1 nkeep" } }
        { { $link 2keep } { $snippet "2 nkeep" } }
        { { $link 3keep } { $snippet "3 nkeep" } }
    }
} ;

HELP: ncurry
{ $values { "n" integer } }
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
{ $values { "n" integer } }
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

HELP: cleave*
{ $values { "n" integer } }
{ $description "Like " { $link cleave } ", but instead of taking a single array of quotations, cleaves using quotations taken from the top " { $snippet "n" } " elements of the datastack." }
{ $notes "This word can be used with " { $link apply-curry } " to generalize the " { $snippet "bi-curry@ bi" } " or " { $snippet "tri-curry@ tri" } " dataflow patterns." } ;

HELP: spread*
{ $values { "n" integer } }
{ $description "Like " { $link spread } ", but instead of taking a single array of quotations, spreads using quotations taken from the top " { $snippet "n" } " elements of the datastack." }
{ $notes "This word can be used with " { $link apply-curry } " to generalize the " { $snippet "bi-curry@ bi*" } " or " { $snippet "tri-curry@ tri*" } " dataflow patterns." } ;

HELP: apply-curry
{ $values { "a..." { $snippet "n" } " values on the datastack" } { "quot" quotation } { "n" integer } }
{ $description "Curries each of the top " { $snippet "n" } " items of the datastack onto " { $snippet "quot" } ", leaving " { $snippet "n" } " quotations on the datastack. A generalization of " { $link bi-curry@ } " and " { $link tri-curry@ } "." }
{ $notes "This word can be used with " { $link cleave* } " and " { $link spread* } " to generalize dataflow patterns such as " { $snippet "bi-curry@ bi" } ", " { $snippet "tri-curry@ tri" } ", " { $snippet "bi-curry@ bi*" } ", and " { $snippet "tri-curry@ tri*" } "." } ;

HELP: cleave-curry
{ $values { "a" object } { "quot..." { $snippet "n" } " quotations on the datastack" } { "n" integer } }
{ $description "Curries " { $snippet "a" } " onto the " { $snippet "n" } " quotations on the top of the datastack. A generalization of " { $link bi-curry } " and " { $link tri-curry } "." }
{ $notes "This word can be used with " { $link cleave* } " and " { $link spread* } " to generalize dataflow patterns such as " { $snippet "bi-curry bi" } ", " { $snippet "tri-curry tri" } ", " { $snippet "bi-curry bi*" } ", and " { $snippet "tri-curry tri*" } "." } ;

HELP: spread-curry
{ $values { "a..." { $snippet "n" } " objects on the datastack" } { "quot..." { $snippet "n" } " quotations on the datastack" } { "n" integer } }
{ $description "Curries the " { $snippet "n" } " quotations on the top of the datastack with the " { $snippet "n" } " values just below them. A generalization of " { $link bi-curry* } " and " { $link tri-curry* } "." }
{ $notes "This word can be used with " { $link cleave* } " and " { $link spread* } " to generalize dataflow patterns such as " { $snippet "bi-curry* bi" } ", " { $snippet "tri-curry* tri" } ", " { $snippet "bi-curry* bi*" } ", and " { $snippet "tri-curry* tri*" } "." } ;

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

HELP: nreverse
{ $values { "n" integer } }
{ $description "Reverses the order of the top " { $snippet "n" } " stack elements." }
{ $examples
  { $example
    "USING: arrays generalizations prettyprint ;"
    "10 20 30 40 4 nreverse 4array ."
    "{ 40 30 20 10 }"
  }
} ;

HELP: n*quot
{ $values
    { "n" integer } { "quot" quotation }
    { "quotquot" quotation }
}
{ $examples
    { $example "USING: generalizations prettyprint math ;"
               "3 [ + ] n*quot ."
               "[ + + + ]"
    }
}
{ $description "Construct a quotation containing the contents of " { $snippet "seq" } " repeated " { $snippet "n" } " times." } ;

ARTICLE: "shuffle-generalizations" "Generalized shuffle words"
{ $subsections
    ndup
    dupn
    npick
    nrot
    -nrot
    nnip
    ndrop
    mnswap
    nweave
    nreverse
} ;

ARTICLE: "combinator-generalizations" "Generalized combinators"
{ $subsections
    ndip
    nkeep
    napply
    ncleave
    nspread
    cleave*
    spread*
    apply-curry
    cleave-curry
    spread-curry
} ;

ARTICLE: "other-generalizations" "Additional generalizations"
{ $subsections
    ncurry
    nwith
    nsum
} ;

ARTICLE: "generalizations" "Generalized shuffle words and combinators"
"The " { $vocab-link "generalizations" } " vocabulary defines a number of stack shuffling words and combinators for use in "
"macros where the arity of the input quotations depends on an "
"input parameter."
{ $subsections
    "shuffle-generalizations"
    "combinator-generalizations"
    "other-generalizations"
}
"Also see the " { $vocab-link "sequences.generalizations" } " vocabulary for generalized sequence operations." ;

ABOUT: "generalizations"

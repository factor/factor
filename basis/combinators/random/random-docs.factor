! Copyright (C) 2010 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators.random.private help.markup help.syntax
kernel math quotations random sequences ;
IN: combinators.random

HELP: call-random
{ $values { "seq" "a sequence of quotations" } }
{ $description "Calls a random quotation from the given sequence of quotations." } ;

HELP: execute-random
{ $values { "seq" "a sequence of words" } }
{ $description "Executes a random word from the given sequence of quotations." } ;

HELP: ifp
{ $values
    { "p" "a number between 0 and 1" } { "true" quotation } { "false" quotation }
}
{ $description "Calls the " { $snippet "true" } " quotation with probability " { $snippet "p" }
" and the " { $snippet "false" } " quotation with probability (1-" { $snippet "p" } ")." } ;

HELP: casep
{ $values
    { "assoc" "a sequence of probability/quotations pairs with an optional quotation at the end" }
}
{ $description "Calls the different quotations randomly with the given probability. The optional quotation at the end "
"will be given a probability so that the sum of the probabilities is one. Therefore, the sum of the probabilities "
"must be exactly one when no default quotation is given, or between zero and one when it is given. "
"Additionally, all probabilities must be numbers between 0 and 1. "
"These rules are enforced during the macro expansion by throwing " { $link bad-probabilities } " "
"if they are not respected." }
{ $examples
    "The following two forms will output 1 with 0.2 probability, 2 with 0.3 probability and 3 with 0.5 probability"
    { $code
        "USING: combinators.random prettyprint ;"
        "{"
        "    { 0.2 [ 1 ] }"
        "    { 0.3 [ 2 ] }"
        "    { 0.5 [ 3 ] }"
        "} casep ."
    }
    $nl
    { $code
        "USING: combinators.random prettyprint ;"
        "{"
        "    { 0.2 [ 1 ] }"
        "    { 0.3 [ 2 ] }"
        "    [ 3 ]"
        "} casep ."
    }

}

{ $see-also casep* } ;

HELP: casep*
{ $values
    { "assoc" "a sequence of probability/word pairs with an optional quotation at the end" }
}
{ $description "Calls the different quotations randomly with the given probability. Unlike " { $link casep } ", "
"the probabilities are interpreted as conditional probabilities. "
"All probabilities must be numbers between 0 and 1. "
"The sequence must end with a pair whose probability is one, or a quotation."
"These rules are enforced during the macro expansion by throwing " { $link bad-probabilities } " "
"if they are not respected." }
{ $examples
    "The following two forms will output 1 with 0.5 probability, 2 with 0.25 probability and 3 with 0.25 probability"
    { $code
        "USING: combinators.random prettyprint ;"
        "{"
        "    { 0.5 [ 1 ] }"
        "    { 0.5 [ 2 ] }"
        "    { 1 [ 3 ] }"
        "} casep* ."
    }
    $nl
    { $code
        "USING: combinators.random prettyprint ;"
        "{"
        "    { 0.5 [ 1 ] }"
        "    { 0.5 [ 2 ] }"
        "    [ 3 ]"
        "} casep* ."
    }

}
{ $see-also casep } ;

HELP: unlessp
{ $values
    { "p" "a number between 0 and 1" } { "false" quotation }
}
{ $description "Variant of " { $link ifp } " with no " { $snippet "true" } " quotation." } ;

HELP: whenp
{ $values
    { "p" "a number between 0 and 1" } { "true" quotation }
}
{ $description "Variant of " { $link ifp } " with no " { $snippet "false" } " quotation." } ;

ARTICLE: "combinators.random" "Random combinators"
"The " { $vocab-link "combinators.random" } " vocabulary implements simple combinators to easily express random choices"
" between multiple code paths."
$nl
"For all these combinators, the stack effect of the different given quotations or words must be the same."
$nl
"Variants of if, when and unless:"
{ $subsections
    ifp
    whenp
    unlessp }
"Variants of case:"
{ $subsections
    casep
    casep*
    call-random
    execute-random
} ;

ABOUT: "combinators.random"

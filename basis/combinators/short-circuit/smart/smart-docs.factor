! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax quotations ;
IN: combinators.short-circuit.smart

HELP: &&
{ $values
    { "quots" "a sequence of quotations" }
    { "quot" quotation } }
{ $description "Infers the number of arguments that each quotation takes from the stack. Each quotation must take the same number of arguments. Returns true if every quotation yields true, and stops early if one yields false." }
{ $examples "Smart combinators will infer the two inputs:"
    { $example "USING: prettyprint kernel math combinators.short-circuit.smart ;"
    "2 3 { [ + 5 = ] [ - -1 = ] } && ."
    "t"
    }
} ;

HELP: ||
{ $values
    { "quots" "a sequence of quotations" }
    { "quot" quotation } }
{ $description "Infers the number of arguments that each quotation takes from the stack. Each quotation must take the same number of arguments. Returns true if any quotation yields true, and stops early when one yields true." }
{ $examples "Smart combinators will infer the two inputs:"
    { $example "USING: prettyprint kernel math combinators.short-circuit.smart ;"
    "2 3 { [ - 1 = ] [ + 5 = ] } || ."
    "t"
    }
} ;

ARTICLE: "combinators.short-circuit.smart" "Smart short-circuit combinators"
"The " { $vocab-link "combinators.short-circuit.smart" } " vocabulary is similar to " { $vocab-link "combinators.short-circuit" } " except the combinators here infer the number of inputs that the sequence of quotations takes."
$nl
"Generalized AND:"
{ $subsections && }
"Generalized OR:"
{ $subsections || } ;

ABOUT: "combinators.short-circuit.smart"

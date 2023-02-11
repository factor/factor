! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math quotations ;
IN: combinators.short-circuit

HELP: 0&&
{ $values { "quots" "a sequence of quotations with stack effect " { $snippet "( -- ? )" } } { "?" "the result of the last quotation, or " { $link f } } }
{ $description "If every quotation in the sequence outputs a true value, outputs the result of the last quotation, otherwise outputs " { $link f } "." } ;

HELP: 0||
{ $values { "quots" "a sequence of quotations with stack effect " { $snippet "( -- ? )" } } { "?" "the first true result, or " { $link f } } }
{ $description "If every quotation in the sequence outputs " { $link f } ", outputs " { $link f } ", otherwise outputs the result of the first quotation that did not yield " { $link f } "." } ;

HELP: 1&&
{ $values { "obj" object } { "quots" "a sequence of quotations with stack effect " { $snippet "( obj -- ? )" } } { "?" "the result of the last quotation, or " { $link f } } }
{ $description "If every quotation in the sequence outputs a true value, outputs the result of the last quotation, otherwise outputs " { $link f } "." } ;

HELP: 1||
{ $values { "obj" object } { "quots" "a sequence of quotations with stack effect " { $snippet "( obj -- ? )" } } { "?" "the first true result, or " { $link f } } }
{ $description "Returns true if any quotation in the sequence returns true. Each quotation takes the same element from the datastack and must return a boolean." } ;

HELP: 2&&
{ $values { "obj1" object } { "obj2" object } { "quots" "a sequence of quotations with stack effect " { $snippet "( obj1 obj2 -- ? )" } } { "?" "the result of the last quotation, or " { $link f } } }
{ $description "If every quotation in the sequence outputs a true value, outputs the result of the last quotation, otherwise outputs " { $link f } "." } ;

HELP: 2||
{ $values { "obj1" object } { "obj2" object } { "quots" "a sequence of quotations with stack effect " { $snippet "( obj1 obj2 -- ? )" } } { "?" "the first true result, or " { $link f } } }
{ $description "Returns true if any quotation in the sequence returns true. Each quotation takes the same two elements from the datastack and must return a boolean." } ;

HELP: 3&&
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "quots" "a sequence of quotations with stack effect " { $snippet "( obj1 obj2 obj3 -- ? )" } } { "?" "the result of the last quotation, or " { $link f } } }
{ $description "If every quotation in the sequence outputs a true value, outputs the result of the last quotation, otherwise outputs " { $link f } "." } ;

HELP: 3||
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "quots" "a sequence of quotations with stack effect " { $snippet "( obj1 obj2 obj3 -- ? )" } } { "?" "the first true result, or " { $link f } } }
{ $description "Returns true if any quotation in the sequence returns true. Each quotation takes the same three elements from the datastack and must return a boolean." } ;

HELP: n&&
{ $values
    { "quots" "a sequence of quotations" } { "n" integer }
    { "quot" quotation } }
{ $description "A macro that rewrites the code to pass " { $snippet "n" } " parameters from the stack to each quotation, evaluating the result in the same manner as " { $link 0&& } "." } ;

HELP: n||
{ $values
    { "quots" "a sequence of quotations" } { "n" integer }
    { "quot" quotation } }
{ $description "A macro that rewrites the code to pass " { $snippet "n" } " parameters from the stack to each OR quotation." } ;

ARTICLE: "combinators.short-circuit" "Short-circuit combinators"
"The " { $vocab-link "combinators.short-circuit" } " vocabulary stops a computation early once a condition is met." $nl
"AND combinators:"
{ $subsections
    0&&
    1&&
    2&&
    3&&
}
"OR combinators:"
{ $subsections
    0||
    1||
    2||
    3||
}
"Generalized combinators:"
{ $subsections
    n&&
    n||
}
;

ABOUT: "combinators.short-circuit"

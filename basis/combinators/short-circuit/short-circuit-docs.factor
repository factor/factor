! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string quotations
math ;
IN: combinators.short-circuit

HELP: 0&&
{ $values
     { "quots" "a sequence of quotations" }
     { "quot" quotation } }
{ $description "Returns true if every quotation in the sequence of quotations returns true." } ;

HELP: 0||
{ $values
     { "quots" "a sequence of quotations" }
     { "quot" quotation } }
{ $description "Returns true if any quotation in the sequence returns true." } ;

HELP: 1&&
{ $values
     { "quots" "a sequence of quotations" }
     { "quot" quotation } }
{ $description "Returns true if every quotation in the sequence of quotations returns true. Each quotation gets the same element from the datastack and must output a boolean." } ;

HELP: 1||
{ $values
     { "quots" "a sequence of quotations" }
     { "quot" quotation } }
{ $description "Returns true if any quotation in the sequence returns true. Each quotation takes the same element from the datastack and must return a boolean." } ;

HELP: 2&&
{ $values
     { "quots" "a sequence of quotations" }
     { "quot" quotation } }
{ $description "Returns true if every quotation in the sequence of quotations returns true. Each quotation gets the same two elements from the datastack and must output a boolean." } ;

HELP: 2||
{ $values
     { "quots" "a sequence of quotations" }
     { "quot" quotation } }
{ $description "Returns true if any quotation in the sequence returns true. Each quotation takes the same two elements from the datastack and must return a boolean." } ;

HELP: 3&&
{ $values
     { "quots" "a sequence of quotations" }
     { "quot" quotation } }
{ $description "Returns true if every quotation in the sequence of quotations returns true. Each quotation gets the same three elements from the datastack and must output a boolean." } ;

HELP: 3||
{ $values
     { "quots" "a sequence of quotations" }
     { "quot" quotation } }
{ $description "Returns true if any quotation in the sequence returns true. Each quotation takes the same three elements from the datastack and must return a boolean." } ;

HELP: n&&
{ $values
     { "quots" "a sequence of quotations" } { "N" integer }
     { "quot" quotation } }
{ $description "A macro that reqrites the code to pass " { $snippet "n" } " parameters from the stack to each AND quotation." } ;

HELP: n||
{ $values
     { "quots" "a sequence of quotations" } { "n" integer }
     { "quot" quotation } }
{ $description "A macro that reqrites the code to pass " { $snippet "n" } " parameters from the stack to each OR quotation." } ;

ARTICLE: "combinators.short-circuit" "Short-circuit combinators"
"The " { $vocab-link "combinators.short-circuit" } " vocabulary stops a computation early once a condition is met." $nl
"AND combinators:"
{ $subsection 0&& }
{ $subsection 1&& }
{ $subsection 2&& }
{ $subsection 3&& }
"OR combinators:"
{ $subsection 0|| }
{ $subsection 1|| }
{ $subsection 2|| }
{ $subsection 3|| }
"Generalized combinators:"
{ $subsection n&& }
{ $subsection n|| }
;

ABOUT: "combinators.short-circuit"

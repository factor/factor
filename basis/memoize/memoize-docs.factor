! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup words quotations effects ;
IN: memoize

ARTICLE: "memoize" "Memoization"
"The " { $vocab-link "memoize" } " vocabulary implements a simple form of memoization, which is when a word caches results for every unique set of inputs that is supplied. Calling a memoized word with the same inputs more than once does not recalculate anything."
$nl
"Memoization is useful in situations where the set of possible inputs is small, but the results are expensive to compute and should be cached. Memoized words should not have any side effects."
$nl
"Defining a memoized word at parse time:"
{ $subsection POSTPONE: MEMO: }
"Defining a memoized word at run time:"
{ $subsection define-memoized }
"Clearing memoized results:"
{ $subsection reset-memoized } ;

ABOUT: "memoize"

HELP: define-memoized
{ $values { "word" word } { "quot" quotation } { "effect" effect } }
{ $description "defines the given word at runtime as one which memoizes its output given a particular input" }
{ $notes "A maximum of four input and four output arguments can be used" }
{ $see-also POSTPONE: MEMO: } ;

HELP: MEMO:
{ $syntax "MEMO: word ( stack -- effect ) definition ;" }
{ $description "defines the given word at parsetime as one which memoizes its output given a particular input. The stack effect is mandatory." }
{ $notes "A maximum of four input and four output arguments can be used" }
{ $see-also define-memoized } ;

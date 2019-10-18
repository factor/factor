! Copyright (C) 2007 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: memoize help.syntax help.markup ;

HELP: define-memoized
{ $values { "word" "the word to be defined" } { "quot" "a quotation" } }
{ $description "defines the given word at runtime as one which memoizes its output given a particular input" }
{ $notes "A maximum of four input and four output arguments can be used" }
{ $see-also POSTPONE: MEMO: } ;

HELP: MEMO:
{ $syntax "MEMO: word ( stack -- effect ) definition ;" }
{ $description "defines the given word at parsetime as one which memoizes its output given a particular input. The stack effect is mandatory." }
{ $notes "A maximum of four input and four output arguments can be used" }
{ $see-also define-memoized } ;

! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup words quotations effects ;
IN: memoize

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

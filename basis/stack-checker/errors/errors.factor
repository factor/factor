! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel stack-checker.values ;
IN: stack-checker.errors

TUPLE: inference-error ;

ERROR: do-not-compile < inference-error word ;

ERROR: literal-expected < inference-error what ;

ERROR: unbalanced-branches-error < inference-error branches quots ;

ERROR: too-many->r < inference-error ;

ERROR: too-many-r> < inference-error ;

ERROR: missing-effect < inference-error word ;

ERROR: effect-error < inference-error inferred declared ;

ERROR: recursive-quotation-error < inference-error quot ;

ERROR: undeclared-recursion-error < inference-error word ;

ERROR: diverging-recursion-error < inference-error word ;

ERROR: unbalanced-recursion-error < inference-error word height ;

ERROR: inconsistent-recursive-call-error < inference-error word ;

ERROR: unknown-primitive-error < inference-error ;

ERROR: transform-expansion-error < inference-error word error ;

ERROR: bad-declaration-error < inference-error declaration ;

M: object (literal) "literal value" literal-expected ;
! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: vocabs.loader ;
IN: stack-checker.errors

TUPLE: inference-error ;

ERROR: do-not-compile < inference-error word ;

ERROR: bad-macro-input < inference-error macro ;

ERROR: unknown-macro-input < inference-error macro ;

ERROR: too-many->r < inference-error ;

ERROR: too-many-r> < inference-error ;

ERROR: missing-effect < inference-error word ;

ERROR: effect-error < inference-error inferred declared ;

ERROR: recursive-quotation-error < inference-error quot ;

ERROR: undeclared-recursion-error < inference-error word ;

ERROR: diverging-recursion-error < inference-error word ;

ERROR: unbalanced-recursion-error < inference-error word height ;

ERROR: inconsistent-recursive-call-error < inference-error word ;

ERROR: transform-expansion-error < inference-error error continuation word ;

ERROR: bad-declaration-error < inference-error declaration ;

ERROR: unbalanced-branches-error < inference-error word quots declareds actuals ;

{ "stack-checker.errors" "debugger" } "stack-checker.errors.prettyprint" require-when

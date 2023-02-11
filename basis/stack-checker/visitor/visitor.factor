! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces ;
IN: stack-checker.visitor

SYMBOL: stack-visitor

HOOK: child-visitor stack-visitor ( -- visitor )

: nest-visitor ( -- ) child-visitor stack-visitor set ;

HOOK: #introduce, stack-visitor ( values -- )
HOOK: #call, stack-visitor ( inputs outputs word -- )
HOOK: #call-recursive, stack-visitor ( inputs outputs word -- )
HOOK: #push, stack-visitor ( literal value -- )
HOOK: #shuffle, stack-visitor ( in-d out-d in-r out-r mapping -- )
HOOK: #drop, stack-visitor ( values -- )
HOOK: #>r, stack-visitor ( inputs outputs -- )
HOOK: #r>, stack-visitor ( inputs outputs -- )
HOOK: #terminate, stack-visitor ( in-d in-r -- )
HOOK: #if, stack-visitor ( ? true false -- )
HOOK: #dispatch, stack-visitor ( n branches -- )
HOOK: #phi, stack-visitor ( d-phi-in d-phi-out terminated -- )
HOOK: #declare, stack-visitor ( declaration -- )
HOOK: #return, stack-visitor ( stack -- )
HOOK: #enter-recursive, stack-visitor ( label inputs outputs -- )
HOOK: #return-recursive, stack-visitor ( label inputs outputs -- )
HOOK: #recursive, stack-visitor ( label inputs visitor -- )
HOOK: #copy, stack-visitor ( inputs outputs -- )
HOOK: #alien-invoke, stack-visitor ( params in-d out-d -- )
HOOK: #alien-indirect, stack-visitor ( params in-d out-d -- )
HOOK: #alien-assembly, stack-visitor ( params in-d out-d -- )
HOOK: #alien-callback, stack-visitor ( params child -- )

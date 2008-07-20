! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces ;
IN: stack-checker.visitor

SYMBOL: dataflow-visitor

HOOK: child-visitor dataflow-visitor ( -- visitor )

: nest-visitor ( -- ) child-visitor dataflow-visitor set ;

HOOK: #introduce, dataflow-visitor ( values -- )
HOOK: #call, dataflow-visitor ( inputs outputs word -- )
HOOK: #call-recursive, dataflow-visitor ( inputs outputs word -- )
HOOK: #push, dataflow-visitor ( literal value -- )
HOOK: #shuffle, dataflow-visitor ( inputs outputs mapping -- )
HOOK: #drop, dataflow-visitor ( values -- )
HOOK: #>r, dataflow-visitor ( inputs outputs -- )
HOOK: #r>, dataflow-visitor ( inputs outputs -- )
HOOK: #terminate, dataflow-visitor ( -- )
HOOK: #if, dataflow-visitor ( ? true false -- )
HOOK: #dispatch, dataflow-visitor ( n branches -- )
HOOK: #phi, dataflow-visitor ( d-phi-in d-phi-out r-phi-in r-phi-out -- )
HOOK: #declare, dataflow-visitor ( inputs outputs declaration -- )
HOOK: #return, dataflow-visitor ( label stack -- )
HOOK: #recursive, dataflow-visitor ( word label inputs outputs visitor -- )
HOOK: #copy, dataflow-visitor ( inputs outputs -- )

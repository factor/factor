! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces optimizer.backend optimizer.def-use
optimizer.known-words optimizer.math inference.class ;
IN: optimizer

SYMBOL: optimize-count

: optimize-1 ( node -- newnode ? )
    [
        global [ optimize-count inc ] bind
        H{ } clone class-substitutions set
        H{ } clone literal-substitutions set
        H{ } clone value-substitutions set
        dup compute-def-use
        kill-values
        dup infer-classes
        optimizer-changed off
        optimize-nodes
        optimizer-changed get
    ] with-scope ;

: optimize ( node -- newnode )
    optimize-1 [ optimize ] when ;

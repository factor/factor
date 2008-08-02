! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dequeues namespaces sequences fry ;
IN: compiler.tree.escape-analysis.work-list

SYMBOL: work-list

: add-escaping-values ( values -- )
    work-list get '[ , push-front ] each ;

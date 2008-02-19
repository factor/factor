! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists threads kernel arrays sequences ;
IN: concurrency.conditions

: notify-1 ( dlist -- )
    dup dlist-empty? [ drop ] [ pop-back second resume ] if ;

: notify-all ( dlist -- )
    [ second resume ] dlist-slurp yield ;

: wait ( queue timeout status -- )
    >r [ 2array swap push-front ] r> suspend 3drop ; inline

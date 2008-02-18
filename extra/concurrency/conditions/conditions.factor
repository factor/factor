! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists threads kernel arrays sequences ;
IN: concurrency.conditions

: notify-1 ( dlist -- )
    dup dlist-empty? [ pop-back resume ] [ drop ] if ;

: notify-all ( dlist -- )
    [ second resume ] dlist-slurp yield ;

: wait ( queue timeout -- queue timeout )
    [ 2array swap push-front ] suspend 3drop ; inline

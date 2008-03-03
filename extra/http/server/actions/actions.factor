! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: http.server.actions

TUPLE: action quot params method ;

C: <action> action

: extract-params ( assoc action -- ... )
    params>> [ first2 >r swap at r> call ] with each ;

: call-action ;

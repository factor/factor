! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel USING: errors lists namespaces sequences ;

: reify ( quot -- )
    >r datastack >pop> callstack >pop> namestack catchstack
    r> call ;

: (callcc) cons cons cons cons swap call ;

: continue0 ( ds rs ns cs -- )
    set-catchstack set-namestack
    >r set-datastack r> set-callstack ;

: callcc0 ( code -- )
    #! Calls the code with a special quotation at the top of the
    #! stack. The quotation has stack effect:
    #!
    #! ( -- ... )
    #!
    #! When called, the quotation restores execution state to
    #! the point after the callcc0 call.
    [ [ continue0 ] (callcc) ] reify ;

: continue1 ( obj ds rs ns cs -- obj )
    set-catchstack set-namestack
    rot >r >r set-datastack r> r> swap set-callstack ;

: callcc1 ( code -- )
    #! Calls the code with a special quotation at the top of the
    #! stack. The quotation has stack effect:
    #!
    #! ( X -- ... )
    #!
    #! When called, the quotation restores execution state to
    #! the point after the callcc1 call, and places X at the top
    #! of the original datastack.
    [ [ continue1 ] (callcc) ] reify ;

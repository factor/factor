! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: compiler-backend errors generic lists inference kernel
math namespaces prettyprint sequences
strings words ;

GENERIC: linearize* ( node -- )

: linearize ( dataflow -- linear )
    #! Transform dataflow IR into linear IR. This strips out
    #! stack flow information, and flattens conditionals into
    #! jumps and labels.
    [ %prologue , linearize* ] { } make ;

: linearize-next node-successor linearize* ;

M: f linearize* ( f -- ) drop ;

M: node linearize* ( node -- ) linearize-next ;

M: #label linearize* ( node -- )
    <label> dup %return-to , >r
    dup node-param %label ,
    dup node-child linearize*
    r> %label ,
    linearize-next ;

: ?tail-call ( node caller jumper -- next )
    >r >r dup node-successor #return? [
        node-param r> drop r> execute ,
    ] [
        dup node-param r> execute , r> drop linearize-next
    ] ifte ; inline

: intrinsic ( #call -- quot ) node-param "intrinsic" word-prop ;

M: #call linearize* ( node -- )
    dup intrinsic [
        dupd call linearize-next
    ] [
        \ %call \ %jump ?tail-call
    ] ifte* ;

M: #call-label linearize* ( node -- )
    \ %call-label \ %jump-label ?tail-call ;

: ifte-head ( label -- ) in-1  -1 %inc-d , 0 %jump-t , ;

M: #ifte linearize* ( node -- )
    node-children first2
    <label> dup ifte-head
    swap linearize* ( false branch )
    %label , ( branch target of BRANCH-T )
    linearize* ( true branch ) ;

: dispatch-head ( vtable -- label/code )
    #! Output the jump table insn and return a list of
    #! label/branch pairs.
    in-1
    -1 %inc-d ,
    0 %untag-fixnum ,
    0 %dispatch ,
    [ <label> dup %target-label ,  cons ] map
    %end-dispatch , ;

: dispatch-body ( label/param -- )
    [ uncons %label , linearize* ] each ;

M: #dispatch linearize* ( vtable -- )
    #! The parameter is a list of nodes, each one is a branch to
    #! take in case the top of stack has that type.
    node-children dispatch-head dispatch-body ;

M: #return linearize* ( node -- )
    drop f %return , ;

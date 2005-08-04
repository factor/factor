! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: compiler-backend errors generic lists inference kernel
kernel-internals math namespaces prettyprint sequences
strings words ;

GENERIC: linearize-node* ( node -- )

M: f linearize-node* ( f -- ) drop ;

M: node linearize-node* ( node -- ) drop ;

: linearize-node ( node -- )
    [
        dup linearize-node* node-successor linearize-node
    ] when* ;

: linearize ( dataflow -- linear )
    #! Transform dataflow IR into linear IR. This strips out
    #! stack flow information, and flattens conditionals into
    #! jumps and labels.
    [ %prologue , linearize-node ] make-list ;

M: #label linearize-node* ( node -- )
    <label> dup %return-to , >r
    dup node-param %label ,
    node-children first linearize-node
    f %return ,
    r> %label , ;

M: #simple-label linearize-node* ( node -- )
    node-children first linearize-node ;

M: #call linearize-node* ( node -- )
    dup node-param
    dup "intrinsic" word-prop [
        call
    ] [
        %call , drop
    ] ?ifte ;

M: #call-label linearize-node* ( node -- )
    node-param %call-label , ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

GENERIC: load-value ( vreg n value -- )

M: object load-value ( vreg n value -- )
    drop %peek-d , ;

: push-literal ( vreg value -- )
    literal-value dup
    immediate? [ %immediate ] [ %indirect ] ifte , ;

M: safe-literal load-value ( vreg n value -- )
    nip push-literal ;

: push-1 ( value -- ) 0 swap push-literal ;

M: #push linearize-node* ( node -- )
    node-out-d dup length dup %inc-d ,
    1 - swap [ push-1 0 over %replace-d , ] each drop ;

M: #drop linearize-node* ( node -- )
    node-in-d length %dec-d , ;

: ifte-head ( label -- )
    in-1  1 %dec-d , 0 %jump-t , ;

M: #ifte linearize-node* ( node -- )
    #! The parameter is a list of two lists, each one a dataflow
    #! IR.
    node-children 2unseq  <label> [
        ifte-head
        linearize-node ( false branch )
        <label> dup %jump-label ,
    ] keep %label , ( branch target of BRANCH-T )
    swap linearize-node ( true branch )
    %label , ( branch target of false branch end ) ;

: dispatch-head ( vtable -- end label/code )
    #! Output the jump table insn and return a list of
    #! label/branch pairs.
    in-1
    1 %dec-d ,
    0 %untag-fixnum ,
    0 %dispatch ,
    <label> ( end label ) swap
    [ <label> dup %target-label ,  cons ] map
    %end-dispatch , ;

: dispatch-body ( end label/param -- )
    #! Output each branch, with a jump to the end label.
    [ uncons %label , linearize-node %jump-label , ] each-with ;

M: #dispatch linearize-node* ( vtable -- )
    #! The parameter is a list of lists, each one is a branch to
    #! take in case the top of stack has that type.
    node-children dispatch-head dupd dispatch-body %label , ;

M: #return linearize-node* ( node -- )
    drop  f %return , ;

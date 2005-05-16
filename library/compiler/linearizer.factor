! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: compiler-backend inference kernel kernel-internals lists
math namespaces words strings errors prettyprint sequences ;

: >linear ( node -- )
    #! Dataflow OPs have a linearizer word property. This
    #! quotation is executed to convert the node into linear
    #! form.
    "linearizer" [ "No linearizer" throw ] apply-dataflow ;

: (linearize) ( dataflow -- )
    [ >linear ] each ;

: linearize ( dataflow -- linear )
    #! Transform dataflow IR into linear IR. This strips out
    #! stack flow information, flattens conditionals into
    #! jumps and labels, and turns dataflow IR nodes into
    #! lists where the first element is an operation, and the
    #! rest is arguments.
    [ %prologue , (linearize) ] make-list ;

: linearize-label ( node -- )
    #! Labels are tricky, because they might contain non-tail
    #! calls. So we push the address of the location right after
    #! the #label , then linearize the #label , then add a #return
    #! node to the linear IR. The simplifier will take care of
    #! this in the common case where the labelled block does
    #! not contain non-tail recursive calls to itself.
    <label> dup %return-to , >r
    dup [ node-label get ] bind %label ,
    [ node-param get ] bind (linearize)
    f %return ,
    r> %label , ;

#label [
    linearize-label
] "linearizer" set-word-prop

#call [
    [ node-param get ] bind %call ,
] "linearizer" set-word-prop

#call-label [
    [ node-param get ] bind %call-label ,
] "linearizer" set-word-prop

: ifte-head ( label -- )
    in-1  1 %dec-d , 0 %jump-t , ;

: linearize-ifte ( param -- )
    #! The parameter is a list of two lists, each one a dataflow
    #! IR.
    2unlist  <label> [
        ifte-head
        (linearize) ( false branch )
        <label> dup %jump-label ,
    ] keep %label , ( branch target of BRANCH-T )
    swap (linearize) ( true branch )
    %label , ( branch target of false branch end ) ;

\ ifte [
    [ node-param get ] bind linearize-ifte
] "linearizer" set-word-prop

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
    [ uncons %label , (linearize) %jump-label , ] each-with ;

: linearize-dispatch ( vtable -- )
    #! The parameter is a list of lists, each one is a branch to
    #! take in case the top of stack has that type.
    dispatch-head dupd dispatch-body %label , ;

\ dispatch [
    [ node-param get ] bind linearize-dispatch
] "linearizer" set-word-prop

#values [ drop ] "linearizer" set-word-prop

#return [ drop f %return , ] "linearizer" set-word-prop

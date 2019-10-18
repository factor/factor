! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: inference kernel lists math namespaces words strings
errors prettyprint kernel-internals ;

! The linear IR is close to assembly language. It also resembles
! Forth code in some sense. It exists so that pattern matching
! optimization can be performed against it.

! Linear IR nodes. This is in addition to the symbols already
! defined in inference vocab.

SYMBOL: #push-immediate
SYMBOL: #push-indirect
SYMBOL: #replace-immediate
SYMBOL: #replace-indirect
SYMBOL: #jump-t ( branch if top of stack is true )
SYMBOL: #jump-t-label ( branch if top of stack is true )
SYMBOL: #jump-f ( branch if top of stack is false )
SYMBOL: #jump-f-label ( branch if top of stack is false )
SYMBOL: #jump ( tail-call )
SYMBOL: #jump-label ( tail-call )
SYMBOL: #return-to ( push addr on C stack )

! dispatch is linearized as dispatch followed by a #target or
! #target-label for each dispatch table entry. The dispatch
! table terminates with #end-dispatch. The linearizer ensures
! the correct number of #targets is emitted.
SYMBOL: #target ( part of jump table )
SYMBOL: #target-label
SYMBOL: #end-dispatch

! on PowerPC, compiled definitions that make subroutine calls
! must have a prologue and epilogue to set up and tear down the
! link register. The epilogue is compiled as part of #return.
SYMBOL: #prologue

: linear, ( node -- )
    #! Add a node to the linear IR.
    [ node-op get node-param get ] bind cons , ;

: >linear ( node -- )
    #! Dataflow OPs have a linearizer word property. This
    #! quotation is executed to convert the node into linear
    #! form.
    "linearizer" [ linear, ] apply-dataflow ;

: (linearize) ( dataflow -- )
    [ >linear ] each ;

: linearize ( dataflow -- linear )
    #! Transform dataflow IR into linear IR. This strips out
    #! stack flow information, flattens conditionals into
    #! jumps and labels, and turns dataflow IR nodes into
    #! lists where the first element is an operation, and the
    #! rest is arguments.
    [ [ #prologue ] , (linearize) ] make-list ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

#push [
    [ node-param get ] bind
    dup immediate? #push-immediate #push-indirect ?
    swons ,
] "linearizer" set-word-prop

: <label> ( -- label )
    gensym  dup t "label" set-word-prop ;

: label? ( obj -- ? )
    dup word? [ "label" word-prop ] [ drop f ] ifte ;

: label, ( label -- )
    #label swons , ;

: linearize-simple-label ( node -- )
    #! Some labels become simple labels after the optimization
    #! stage.
    dup [ node-label get ] bind label,
    [ node-param get ] bind (linearize) ;

#simple-label [
    linearize-simple-label
] "linearizer" set-word-prop

: linearize-label ( node -- )
    #! Labels are tricky, because they might contain non-tail
    #! calls. So we push the address of the location right after
    #! the label, then linearize the label, then add a #return
    #! node to the linear IR. The simplifier will take care of
    #! this in the common case where the labelled block does
    #! not contain non-tail recursive calls to itself.
    <label> dup #return-to swons , >r
    linearize-simple-label
    [ #return ] ,
    r> label, ;

#label [
    linearize-label
] "linearizer" set-word-prop

: linearize-ifte ( param -- )
    #! The parameter is a list of two lists, each one a dataflow
    #! IR.
    2unlist  <label> [
        #jump-t-label swons ,
        (linearize) ( false branch )
        <label> dup #jump-label swons ,
    ] keep label, ( branch target of BRANCH-T )
    swap (linearize) ( true branch )
    label, ( branch target of false branch end ) ;

\ ifte [
    [ node-param get ] bind linearize-ifte
] "linearizer" set-word-prop

: dispatch-head ( vtable -- end label/code )
    #! Output the jump table insn and return a list of
    #! label/branch pairs.
    [ dispatch ] ,
    <label> ( end label ) swap
    [ <label> dup #target-label swons ,  cons ] map
    [ #end-dispatch ] , ;

: dispatch-body ( end label/param -- )
    #! Output each branch, with a jump to the end label.
    [ uncons label, (linearize) #jump-label swons , ] each-with ;

: linearize-dispatch ( vtable -- )
    #! The parameter is a list of lists, each one is a branch to
    #! take in case the top of stack has that type.
    dispatch-head dupd dispatch-body label, ;

\ dispatch [
    [ node-param get ] bind linearize-dispatch
] "linearizer" set-word-prop

#values [ drop ] "linearizer" set-word-prop

#return [ drop [ #return ] , ] "linearizer" set-word-prop

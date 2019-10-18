! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: namespaces hashtables sequences inference kernel
generic ;

SYMBOL: def-use

: used-by ( value -- seq ) def-use get hash ;

: uses-values ( node seq -- )
    [ def-use get [ ?push ] change-hash ] each-with ;

: defs-values ( seq -- )
    #! If there is no value, set it to a new empty vector,
    #! otherwise do nothing.
    [ def-use get [ V{ } like ] change-hash ] each ;

GENERIC: node-def-use ( node -- )

: compute-def-use ( node -- )
    H{ } clone def-use set [ node-def-use ] each-node ;

: (node-def-use) ( node -- )
    dup dup node-in-d uses-values
    dup dup node-in-r uses-values
    dup node-out-d defs-values
    node-out-r defs-values ;

M: object node-def-use (node-def-use) ;

! nodes that don't use their values directly
UNION: #passthru
    #shuffle #>r #r> #call-label #merge #values #entry ;

M: #passthru node-def-use drop ;

M: #return node-def-use
    #! Values returned by local labels can be killed.
    dup node-param [ drop ] [ (node-def-use) ] if ;

! nodes that don't use their values directly
UNION: #killable
    #push #shuffle #>r #r> #call-label #merge #values #entry ;

: purge-invariants ( stacks -- seq )
    #! Output a sequence of values which are not present in the
    #! same position in each sequence of the stacks sequence.
    unify-lengths flip [ all-eq? not ] subset concat ;

M: #label node-def-use
    [
        dup node-in-d ,
        dup node-child node-out-d ,
        dup collect-recursion [ node-in-d , ] each
    ] { } make purge-invariants uses-values ;

: branch-def-use ( #branch -- )
    dup node-children [ last-node node-in-d ] map
    purge-invariants uses-values ;

M: #branch node-def-use
    #! This assumes that the last element of each branch is a
    #! #values node.
    dup branch-def-use (node-def-use) ;

: dead-literals ( -- values )
    def-use get [ >r value? r> empty? and ] hash-subset ;

: kill-node* ( values node -- )
    2dup [ node-in-d remove-all ] keep set-node-in-d
    2dup [ node-out-d remove-all ] keep set-node-out-d
    2dup [ node-in-r remove-all ] keep set-node-in-r
    [ node-out-r remove-all ] keep set-node-out-r ;

: kill-node ( values node -- )
    over hash-empty?
    [ 2drop ] [ [ kill-node* ] each-node-with ] if ;

: kill-values ( node -- )
    #! Remove literals which are not actually used anywhere.
    dead-literals swap kill-node ;

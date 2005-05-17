! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: inference kernel kernel-internals lists namespaces
sequences vectors words words ;

! The optimizer transforms dataflow IR to dataflow IR. Currently
! it removes literals that are eventually dropped, and never
! arise as inputs to any other type of function. Such 'dead'
! literals arise when combinators are inlined and quotations are
! lifted to their call sites. Also, #label nodes are inlined if
! their children do not make a recursive call to the label.

! : scan-literal ( node -- )
!     #! If the node represents a literal push, add the literal to
!     #! the list being constructed.
!     "scan-literal" [ drop ] apply-dataflow ;
! 
! : (scan-literals) ( dataflow -- )
!     [ scan-literal ] each ;
! 
! : scan-literals ( dataflow -- list )
!     [ (scan-literals) ] make-list ;
! 
! : scan-branches ( branches -- )
!     #! Collect all literals from all branches.
!     [ node-param get ] bind [ [ scan-literal ] each ] each ;
! 
! : mentions-literal? ( literal list -- ? )
!     #! Does the given list of result objects refer to this
!     #! literal?
!     [ value= ] some-with? ;
! 
! : consumes-literal? ( literal node -- ? )
!     #! Does the dataflow node consume the literal?
!     [
!         dup node-consume-d get mentions-literal? swap
!         dup node-consume-r get mentions-literal? nip or
!     ] bind ;
! 
! : produces-literal? ( literal node -- ? )
!     #! Does the dataflow node produce the literal?
!     [
!         dup node-produce-d get mentions-literal? swap
!         dup node-produce-r get mentions-literal? nip or
!     ] bind ;
! 
! : (can-kill?) ( literal node -- ? )
!     #! Return false if the literal appears as input to this
!     #! node, and this node is not a stack operation.
!     2dup consumes-literal? >r produces-literal? r> or not ;
! 
! : can-kill? ( literal dataflow -- ? )
!     #! Return false if the literal appears in any node in the
!     #! list.
!     [ dupd "can-kill" [ (can-kill?) ] apply-dataflow ] all? nip ;
! 
! : kill-set ( dataflow -- list )
!     #! Push a list of literals that may be killed in the IR.
!     dup scan-literals [ over can-kill? ] subset nip ;
! 
! SYMBOL: branch-returns
! 
! : can-kill-branches? ( literal node -- ? )
!     #! Check if the literal appears in either branch. This
!     #! assumes that the last element of each branch is a #values
!     #! node.
!     2dup consumes-literal? [
!         2drop f
!     ] [
!         [ node-param get ] bind
!         [
!             dup [
!                 peek [ node-consume-d get >vector ] bind
!             ] map
!             unify-stacks >list
!             branch-returns set
!             [ dupd can-kill? ] all? nip
!         ] with-scope
!     ] ifte ;
! 
! : kill-node ( literals node -- )
!     swap [ over (can-kill?) ] all? [ , ] [ drop ] ifte ;
! 
! : (kill-nodes) ( literals dataflow -- )
!     #! Append live nodes to currently constructing list.
!     [ "kill-node" [ nip , ] apply-dataflow ] each-with ;
! 
! : kill-nodes ( literals dataflow -- dataflow )
!     #! Remove literals and construct a list.
!     [ (kill-nodes) ] make-list ;
! 
! : optimize ( dataflow -- dataflow )
!     #! Remove redundant literals from the IR. The original IR
!     #! is destructively modified.
!     dup kill-set swap kill-nodes ;
! 
! : kill-branches ( literals node -- )
!     [
!         node-param [ [ dupd kill-nodes ] map nip ] change
!     ] extend , ;
! 
! : kill-literal ( literals values -- values )
!     [
!         swap [ swap value= ] some-with? not
!     ] subset-with ;
! 
! #push [
!     [ node-produce-d get ] bind [ literal-value ] map %
! ] "scan-literal" set-word-prop
! 
! #push [ 2drop t ] "can-kill" set-word-prop
! 
! #push [
!     [ node-produce-d [ kill-literal ] change ] extend ,
! ] "kill-node" set-word-prop
! 
! #drop [ 2drop t ] "can-kill" set-word-prop
! 
! #drop [
!     [ node-consume-d [ kill-literal ] change ] extend ,
! ] "kill-node" set-word-prop
! 
! #label [
!     [ node-param get ] bind (scan-literals)
! ] "scan-literal" set-word-prop
! 
! #label [
!     [ node-param get ] bind can-kill?
! ] "can-kill" set-word-prop
! 
! #call-label [
!     [ node-param get ] bind =
! ] "calls-label" set-word-prop
! 
! : calls-label? ( label list -- ? )
!     [ "calls-label" [ 2drop f ] apply-dataflow ] some-with? ;
! 
! #label [
!     [ node-param get ] bind calls-label?
! ] "calls-label" set-word-prop
! 
! : branches-call-label? ( label list -- ? )
!     [ calls-label? ] some-with? ;
! 
! \ ifte [
!     [ node-param get ] bind branches-call-label?
! ] "calls-label" set-word-prop
! 
! \ dispatch [
!     [ node-param get ] bind branches-call-label?
! ] "calls-label" set-word-prop
! 
! #label [ ( literals node -- )
!     [ node-param [ kill-nodes ] change ] extend ,
! ] "kill-node" set-word-prop
! 
! #values [
!     dupd consumes-literal? [
!         branch-returns get mentions-literal?
!     ] [
!         drop t
!     ] ifte
! ] "can-kill" set-word-prop
! 
! \ ifte [ scan-branches ] "scan-literal" set-word-prop
! \ ifte [ can-kill-branches? ] "can-kill" set-word-prop
! \ ifte [ kill-branches ] "kill-node" set-word-prop
! 
! \ dispatch [ scan-branches ] "scan-literal" set-word-prop
! \ dispatch [ can-kill-branches? ] "can-kill" set-word-prop
! \ dispatch [ kill-branches ] "kill-node" set-word-prop
! 
! ! Don't care about inputs to recursive combinator calls
! #call-label [ 2drop t ] "can-kill" set-word-prop
! 
! \ drop [ 2drop t ] "can-kill" set-word-prop
! \ drop [ kill-node ] "kill-node" set-word-prop
! \ dup [ 2drop t ] "can-kill" set-word-prop
! \ dup [ kill-node ] "kill-node" set-word-prop
! \ swap [ 2drop t ] "can-kill" set-word-prop
! \ swap [ kill-node ] "kill-node" set-word-prop
! 
! : kill-mask ( killing inputs -- mask )
!     [ over [ over value= ] some? >boolean nip ] map nip ;
! 
! : reduce-stack-op ( literals node map -- )
!     #! If certain values passing through a stack op are being
!     #! killed, the stack op can be reduced, in extreme cases
!     #! to a no-op.
!     -rot [
!         [ node-consume-d get ] bind kill-mask swap assoc
!     ] keep
!     over [ [ node-op set ] extend , ] [ 2drop ] ifte ;
! 
! \ over [ 2drop t ] "can-kill" set-word-prop
! \ over [
!     [
!         [[ [ f f ] over ]]
!         [[ [ f t ] dup  ]]
!     ] reduce-stack-op
! ] "kill-node" set-word-prop
! 
! \ pick [ 2drop t ] "can-kill" set-word-prop
! \ pick [
!     [
!         [[ [ f f f ] pick ]]
!         [[ [ f f t ] over ]]
!         [[ [ f t f ] over ]]
!         [[ [ f t t ] dup  ]]
!     ] reduce-stack-op
! ] "kill-node" set-word-prop
! 
! \ >r [ 2drop t ] "can-kill" set-word-prop
! \ >r [ kill-node ] "kill-node" set-word-prop
! \ r> [ 2drop t ] "can-kill" set-word-prop
! \ r> [ kill-node ] "kill-node" set-word-prop

: optimize ;

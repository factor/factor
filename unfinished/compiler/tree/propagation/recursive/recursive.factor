! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.tree compiler.tree.propagation.simple
compiler.tree.propagation.branches ;
IN: compiler.tree.propagation.recursive

! M: #recursive child-constraints
!     drop { f } ;
! 
! M: #recursive propagate-around
!     [ infer-children ] [ merge-children ] [ annotate-node ] tri ;
! 
! : classes= ( inferred current -- ? )
!     2dup min-length '[ , tail* ] bi@ sequence= ;
! 
! SYMBOL: fixed-point?
! 
! SYMBOL: nested-labels
! 
! : annotate-entry ( nodes #label -- )
!     [ (merge-classes) ] dip node-child
!     2dup node-output-classes classes=
!     [ 2drop ] [ set-classes fixed-point? off ] if ;
! 
! : init-recursive-calls ( #label -- )
!     #! We set recursive calls to output the empty type, then
!     #! repeat inference until a fixed point is reached.
!     #! Hopefully, our type functions are monotonic so this
!     #! will always converge.
!     returns>> [ dup in-d>> [ null ] { } map>assoc >>classes drop ] each ;
! 
! M: #label propagate-before ( #label -- )
!     [ init-recursive-calls ]
!     [ [ 1array ] keep annotate-entry ] bi ;
! 
! : infer-label-loop ( #label -- )
!     fixed-point? on
!     dup node-child (propagate)
!     dup [ calls>> ] [ suffix ] [ annotate-entry ] tri
!     fixed-point? get [ drop ] [ infer-label-loop ] if ;
! 
! M: #label propagate-around ( #label -- )
!     #! Now merge the types at every recursion point with the
!     #! entry types.
!     [
!         {
!             [ nested-labels get push ]
!             [ annotate-node ]
!             [ propagate-before ]
!             [ infer-label-loop ]
!             [ drop nested-labels get pop* ]
!         } cleave
!     ] with-scope ;
! 
! : find-label ( param -- #label )
!     word>> nested-labels get [ word>> eq? ] with find nip ;
! 
! M: #call-recursive propagate-before ( #call-label -- )
!     [ label>> returns>> (merge-classes) ] [ out-d>> ] bi
!     [ set-value-class ] 2each ;
! 
! M: #return propagate-around
!     nested-labels get length 0 > [
!         dup word>> nested-labels get peek word>> eq? [
!             [ ] [ node-input-classes ] [ in-d>> [ value-class* ] map ] tri
!             classes= not [
!                 fixed-point? off
!                 [ in-d>> value-classes get valid-keys ] keep
!                 set-node-classes
!             ] [ drop ] if
!         ] [ call-next-method ] if
!     ] [ call-next-method ] if ;

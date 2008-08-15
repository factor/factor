! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences namespaces kernel accessors assocs sets fry
arrays combinators columns stack-checker.backend compiler.tree
compiler.tree.combinators compiler.tree.dead-code.liveness
compiler.tree.dead-code.simple ;
IN: compiler.tree.dead-code.branches

M: #if mark-live-values* look-at-inputs ;

M: #dispatch mark-live-values* look-at-inputs ;

: look-at-phi ( value outputs inputs -- )
    [ index ] dip swap dup [ <column> look-at-values ] [ 2drop ] if ;

M: #phi compute-live-values*
    #! If any of the outputs of a #phi are live, then the
    #! corresponding inputs are live too.
    [ [ out-d>> ] [ phi-in-d>> ] bi look-at-phi ]
    [ [ out-r>> ] [ phi-in-r>> ] bi look-at-phi ]
    2bi ;

M: #branch remove-dead-code*
    [ [ (remove-dead-code) ] map ] change-children ;

: remove-phi-inputs ( #phi -- )
    dup [ out-d>> ] [ phi-in-d>> flip ] bi filter-corresponding flip >>phi-in-d
    dup [ out-r>> ] [ phi-in-r>> flip ] bi filter-corresponding flip >>phi-in-r
    drop ;

! SYMBOL: if-node
! 
! : dead-value-indices ( values -- indices )
!     [ length ] keep live-values get
!     '[ , nth , key? not ] filter ; inline
! 
! : drop-d-values ( values indices -- node )
!     [ drop filter-live ] [ nths filter-live ] 2bi
!     [ make-values ] keep
!     [ drop ] [ zip ] 2bi
!     #shuffle ;
! 
! : drop-r-values ( values indices -- nodes )
!     [ dup make-values [ #r> ] keep ] dip
!     drop-d-values dup out-d>> dup make-values #>r
!     3array ;
! 
! : insert-drops ( nodes d-values r-values d-indices r-indices -- nodes' )
!     '[
!         [ , drop-d-values 1array ]
!         [ , drop-r-values ]
!         bi* 3append
!     ] 3map ;
! 
! : hoist-drops ( #phi -- )
!     if-node get swap
!     {
!         [ phi-in-d>> ]
!         [ phi-in-r>> ]
!         [ out-d>> dead-value-indices ]
!         [ out-r>> dead-value-indices ]
!     } cleave
!     '[ , , , , insert-drops ] change-children drop ;

: remove-phi-outputs ( #phi -- )
    [ filter-live ] change-out-d
    [ filter-live ] change-out-r
    drop ;

M: #phi remove-dead-code*
    {
        ! [ hoist-drops ]
        [ remove-phi-inputs ]
        [ remove-phi-outputs ]
        [ ]
    } cleave ;

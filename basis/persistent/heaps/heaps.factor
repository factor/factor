USING: accessors arrays assocs combinators kernel math sequences ;
IN: persistent.heaps
! These are minheaps

<PRIVATE
TUPLE: branch value prio left right ;
TUPLE: empty-heap ;

PREDICATE: singleton-heap < branch
    [ left>> ] [ right>> ] bi [ empty-heap? ] both? ;

C: <branch> branch
: >branch< ( branch -- value prio left right )
    { [ value>> ] [ prio>> ] [ left>> ] [ right>> ] } cleave ;
PRIVATE>

: <persistent-heap> ( -- heap ) T{ empty-heap } ;

: <singleton-heap> ( value prio -- heap )
    <persistent-heap> <persistent-heap> <branch> ;

: pheap-empty? ( heap -- ? ) empty-heap? ;

: empty-pheap ( -- * )
    "Attempt to delete from an empty heap" throw ;

<PRIVATE
: remove-left ( heap -- value prio newheap )
    dup [ left>> ] [ right>> ] bi [ pheap-empty? ] both?
    [ [ value>> ] [ prio>> ] bi <persistent-heap> ]
    [ >branch< swap remove-left -rot [ <branch> ] 2dip rot ] if ;

: both-with? ( obj a b quot -- ? )
   swap [ with ] dip swap both? ; inline

GENERIC: sift-down ( value prio left right -- heap )

: singleton-sift-down ( value prio singleton empty -- heap )
    2over prio>> <= [ <branch> ] [
        drop -rot [ [ value>> ] [ prio>> ] bi ] 2dip
        <singleton-heap> <persistent-heap> <branch>
    ] if ;

M: empty-heap sift-down
    over singleton-heap? [ singleton-sift-down ] [ <branch> ] if ;

:: reroot-left ( value prio left right -- heap )
    left value>> left prio>>
    value prio left left>> left right>> sift-down
    right <branch> ;

:: reroot-right ( value prio left right -- heap )
    right value>> right prio>> left
    value prio right left>> right right>> sift-down
    <branch> ;

M: branch sift-down ! both arguments are branches
    3dup [ prio>> <= ] both-with? [ <branch> ] [
        2dup [ prio>> ] bi@ <= [ reroot-left ] [ reroot-right ] if
    ] if ;
PRIVATE>

GENERIC: pheap-peek ( heap -- value prio )
M: empty-heap pheap-peek empty-pheap ;
M: branch pheap-peek [ value>> ] [ prio>> ] bi ;

GENERIC: pheap-push ( value prio heap -- newheap )

M: empty-heap pheap-push
    drop <singleton-heap> ;

<PRIVATE
: push-top ( value prio heap -- newheap )
    [ [ value>> ] [ prio>> ] [ right>> ] tri pheap-push ]
    [ left>> ] bi <branch> ;

: push-in ( value prio heap -- newheap )
    [ 2nip [ value>> ] [ prio>> ] bi ]
    [ right>> pheap-push ]
    [ 2nip left>> ] 3tri <branch> ;
PRIVATE>

M: branch pheap-push
    2dup prio>> <= [ push-top ] [ push-in ] if ;

: pheap-pop* ( heap -- newheap )
    dup pheap-empty? [ empty-pheap ] [
        dup left>> pheap-empty?
        [ drop <persistent-heap> ]
        [ [ left>> remove-left ] keep right>> swap sift-down ] if
    ] if ;

: pheap-pop ( heap -- newheap value prio )
    [ pheap-pop* ] [ pheap-peek ] bi ;

: assoc>pheap ( assoc -- heap ) ! Assoc is value => prio
    <persistent-heap> swap [ rot pheap-push ] assoc-each ;

: pheap>alist ( heap -- alist )
    [ dup pheap-empty? not ] [ pheap-pop 2array ] produce nip ;

: pheap>values ( heap -- seq ) pheap>alist keys ;

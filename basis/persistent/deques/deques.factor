! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math qualified ;
QUALIFIED: sequences
IN: persistent.deques

! Amortized O(1) push/pop on both ends for single-threaded access
! In a pathological case, if there are m modified versions from the
!   same source, it could take O(m) amortized time per update.

<PRIVATE
TUPLE: cons { car read-only } { cdr read-only } ;
C: <cons> cons

: each ( list quot: ( elt -- ) -- )
    over
    [ [ >r car>> r> call ] [ >r cdr>> r> ] 2bi each ]
    [ 2drop ] if ; inline recursive

: reduce ( list start quot -- end )
    swapd each ; inline

: reverse ( list -- reversed )
    f [ swap <cons> ] reduce ;

: length ( list -- length )
    0 [ drop 1+ ] reduce ;

: cut ( list index -- back front-reversed )
    f swap [ >r [ cdr>> ] [ car>> ] bi r> <cons> ] times ;

: split-reverse ( list -- back-reversed front )
    dup length 2/ cut [ reverse ] bi@ ;
PRIVATE>

TUPLE: deque { lhs read-only } { rhs read-only } ;
: <deque> ( -- deque ) T{ deque } ;

: deque-empty? ( deque -- ? )
    [ lhs>> ] [ rhs>> ] bi or not ;

: push-left ( deque item -- newdeque )
    swap [ lhs>> <cons> ] [ rhs>> ] bi deque boa ;

: push-right ( deque item -- newdeque )
    swap [ rhs>> <cons> ] [ lhs>> ] bi swap deque boa ;

<PRIVATE
: (pop-left) ( deque -- item newdeque )
    [ lhs>> car>> ] [ [ lhs>> cdr>> ] [ rhs>> ] bi deque boa ] bi ;

: transfer-left ( deque -- item newdeque )
    rhs>> [ split-reverse deque boa (pop-left) ]
    [ "Popping from an empty deque" throw ] if* ;
PRIVATE>

: pop-left ( deque -- item newdeque )
    dup lhs>> [ (pop-left) ] [ transfer-left ] if ;

<PRIVATE
: (pop-right) ( deque -- item newdeque )
    [ rhs>> car>> ] [ [ lhs>> ] [ rhs>> cdr>> ] bi deque boa ] bi ;

: transfer-right ( deque -- newdeque item )
    lhs>> [ split-reverse deque boa (pop-left) ]
    [ "Popping from an empty deque" throw ] if* ;
PRIVATE>

: pop-right ( deque -- item newdeque )
    dup rhs>> [ (pop-right) ] [ transfer-right ] if ;

: sequence>deque ( sequence -- deque )
    <deque> [ push-right ] sequences:reduce ;

: deque>sequence ( deque -- sequence )
    [ dup deque-empty? not ] [ pop-left swap ] [ ] sequences:produce nip ;

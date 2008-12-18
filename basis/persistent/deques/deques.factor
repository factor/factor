! Copyback (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math ;
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
    [ [ [ car>> ] dip call ] [ [ cdr>> ] dip ] 2bi each ]
    [ 2drop ] if ; inline recursive

: reduce ( list start quot -- end )
    swapd each ; inline

: reverse ( list -- reversed )
    f [ swap <cons> ] reduce ;

: length ( list -- length )
    0 [ drop 1+ ] reduce ;

: cut ( list index -- back front-reversed )
    f swap [ [ [ cdr>> ] [ car>> ] bi ] dip <cons> ] times ;

: split-reverse ( list -- back-reversed front )
    dup length 2/ cut [ reverse ] bi@ ;
PRIVATE>

TUPLE: deque { front read-only } { back read-only } ;
: <deque> ( -- deque ) T{ deque } ;

<PRIVATE
: flip ( deque -- newdeque )
    [ back>> ] [ front>> ] bi deque boa ;

: flipped ( deque quot -- newdeque )
    [ flip ] dip call flip ;
PRIVATE>

: deque-empty? ( deque -- ? )
    [ front>> ] [ back>> ] bi or not ;

<PRIVATE
: push ( item deque -- newdeque )
    [ front>> <cons> ] [ back>> ] bi deque boa ; inline
PRIVATE>

: push-front ( deque item -- newdeque )
    swap push ;

: push-back ( deque item -- newdeque )
    swap [ push ] flipped ;

<PRIVATE
: remove ( deque -- item newdeque )
    [ front>> car>> ] [ [ front>> cdr>> ] [ back>> ] bi deque boa ] bi ; inline

: transfer ( deque -- item newdeque )
    back>> [ split-reverse deque boa remove ]
    [ "Popping from an empty deque" throw ] if* ; inline

: pop ( deque -- item newdeque )
    dup front>> [ remove ] [ transfer ] if ; inline
PRIVATE>

: pop-front ( deque -- item newdeque )
    pop ;

: pop-back ( deque -- item newdeque )
    [ pop ] flipped ;

: peek-front ( deque -- item ) pop-front drop ;

: peek-back ( deque -- item ) pop-back drop ;

: sequence>deque ( sequence -- deque )
    <deque> [ push-back ] sequences:reduce ;

: deque>sequence ( deque -- sequence )
    [ dup deque-empty? not ] [ pop-front swap ] [ ] sequences:produce nip ;

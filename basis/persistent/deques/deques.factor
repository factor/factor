! Copyright (C) 2008 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: kernel accessors math lists sequences combinators.short-circuit ;
IN: persistent.deques

! Amortized O(1) push/pop on both ends for single-threaded access
! In a pathological case, if there are m modified versions from the
!   same source, it could take O(m) amortized time per update.

<PRIVATE
: split-reverse ( list -- back-reversed front )
    dup llength 2/ lcut lreverse swap ;
PRIVATE>

TUPLE: deque { front read-only } { back read-only } ;
: <deque> ( -- deque )
    T{ deque f +nil+ +nil+ } ;

<PRIVATE
: flip ( deque -- newdeque )
    [ back>> ] [ front>> ] bi deque boa ;

: flipped ( deque quot -- newdeque )
    [ flip ] dip call flip ; inline
PRIVATE>

: deque-empty? ( deque -- ? )
    { [ front>> nil? ] [ back>> nil? ] } 1&& ;

<PRIVATE
: push ( item deque -- newdeque )
    [ front>> cons ] [ back>> ] bi deque boa ; inline
PRIVATE>

: push-front ( deque item -- newdeque )
    swap push ;

: push-back ( deque item -- newdeque )
    swap [ push ] flipped ;

<PRIVATE
: remove ( deque -- item newdeque )
    [ front>> car ] [ [ front>> cdr ] [ back>> ] bi deque boa ] bi ; inline

: transfer ( deque -- item newdeque )
    back>> dup nil?
    [ "Popping from an empty deque" throw ]
    [ split-reverse deque boa remove ] if ; inline

: pop ( deque -- item newdeque )
    dup front>> nil? [ transfer ] [ remove ] if ; inline
PRIVATE>

: pop-front ( deque -- item newdeque )
    pop ;

: pop-back ( deque -- item newdeque )
    [ pop ] flipped ;

: peek-front ( deque -- item )
    pop-front drop ;

: peek-back ( deque -- item )
    pop-back drop ;

: sequence>deque ( sequence -- deque )
    <deque> [ push-back ] reduce ;

: deque>sequence ( deque -- sequence )
    [ dup deque-empty? not ] [ pop-front swap ] produce nip ;

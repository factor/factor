! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors ;

IN: lists

! Lazy List Protocol
MIXIN: list
GENERIC: car   ( cons -- car )
GENERIC: cdr   ( cons -- cdr )
GENERIC: nil?  ( cons -- ? )

TUPLE: cons car cdr ;

C: cons cons

M: cons car ( cons -- car )
    car>> ;

M: cons cdr ( cons -- cdr )
    cdr>> ;

: nil ( -- cons )
  T{ cons f f f } ;

M: cons nil? ( cons -- bool )
    nil eq? ;

: 1list ( obj -- cons )
    nil cons ;

: 2list ( a b -- cons )
    nil cons cons ;

: 3list ( a b c -- cons )
    nil cons cons cons ;
    
: uncons ( cons -- cdr car )
    [ cdr ] [ car ] bi ;

: seq>cons ( seq -- cons )
    <reversed> nil [ f cons swap >>cdr ] reduce ;
    
: (map-cons) ( acc cons quot -- seq )    
    over nil? [ 2drop ]
    [ [ uncons ] dip [ call ] keep swapd [ suffix ] 2dip (map-cons) ] if ;
    
: map-cons ( cons quot -- seq )
    [ { } clone ] 2dip (map-cons) ;
    
: cons>seq ( cons -- array )    
    [ ] map-cons ;
    
: reduce-cons ( cons identity quot -- result )    
    pick nil? [ drop nip ]
    [ [ uncons ] 2dip swapd [ call ] keep reduce-cons ] if ;
    
INSTANCE: cons list
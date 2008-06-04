! Copyright (C) 2008 Chris Double & James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors math arrays vectors classes ;

IN: lists

! List Protocol
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
    
: 2car ( cons -- car caar )    
    [ car ] [ cdr car ] bi ;
    
: 3car ( cons -- car caar caaar )    
    [ car ] [ cdr car ] [ cdr cdr car ] tri ;
    
: uncons ( cons -- cdr car )
    [ cdr ] [ car ] bi ;

: lnth ( n list -- elt )
    swap [ cdr ] times car ;

: (llength) ( list acc -- n )
    over nil? [ nip ] [ [ cdr ] dip 1+ (llength) ] if ;

: llength ( list -- n )
    0 (llength) ;

: leach ( list quot -- )
    over nil? [ 2drop ] [ [ uncons ] dip tuck call leach ] if ; inline
    
: lreduce ( list identity quot -- result )
    swapd leach ; inline
    
: (lmap) ( acc cons quot -- seq )    
    over nil? [ 2drop ]
    [ [ uncons ] dip [ call ] keep swapd [ suffix ] 2dip (lmap) ] if ; inline
    
: lmap ( cons quot -- seq )
    [ { } clone ] 2dip (lmap) ; inline
    
: lmap-as ( cons quot exemplar -- seq )
    [ lmap ] dip like ;
    
: same? ( obj1 obj2 -- ? ) 
    [ class ] bi@ = ;
    
: seq>cons ( seq -- cons )
    [ <reversed> ] keep nil [ tuck same? [ seq>cons ] when f cons swap >>cdr ] with reduce ;
    
: cons>seq ( cons -- array )    
    [ ] lmap ;
    
INSTANCE: cons list
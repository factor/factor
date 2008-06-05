! Copyright (C) 2008 Chris Double & James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors math arrays vectors classes words ;

IN: lists

! List Protocol
MIXIN: list
GENERIC: car   ( cons -- car )
GENERIC: cdr   ( cons -- cdr )
GENERIC: nil?   ( cons -- ?   )
    
TUPLE: cons car cdr ;

C: cons cons

M: cons car ( cons -- car )
    car>> ;

M: cons cdr ( cons -- cdr )
    cdr>> ;
    
SYMBOL: +nil+
M: word nil? +nil+ eq? ;
M: object nil? drop f ;

: nil ( -- +nil+ ) +nil+ ; 
    
: uncons ( cons -- cdr car )
    [ cdr ] [ car ] bi ;
    
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

: lnth ( n list -- elt )
    swap [ cdr ] times car ;

: (llength) ( list acc -- n )
    over nil? [ nip ] [ [ cdr ] dip 1+ (llength) ] if ;

: llength ( list -- n )
    0 (llength) ;

: leach ( list quot -- )
    over nil? [ 2drop ] [ [ uncons swap ] dip tuck [ call ] 2dip leach ] if ; inline
    
: lreduce ( list identity quot -- result )
    swapd leach ; inline
    
: (lmap>array) ( acc cons quot -- newcons )
    over nil? [ 2drop ]
    [ [ uncons ] dip [ call ] keep swapd [ suffix ] 2dip (lmap>array) ] if ; inline
    
: lmap>array ( cons quot -- newcons )
    { } -rot (lmap>array) ; inline
    
: lmap-as ( cons quot exemplar -- seq )
    [ lmap>array ] dip like ;
    
: lmap ( list quot -- newlist )    
    lmap>array <reversed> nil [ swap cons ] reduce ;
    
: same? ( obj1 obj2 -- ? ) 
    [ class ] bi@ = ;
    
: seq>cons ( seq -- cons )
    [ <reversed> ] keep nil [ tuck same? [ seq>cons ] when f cons swap >>cdr ] with reduce ;
    
: cons>seq ( cons -- array )    
    [ dup cons? [ cons>seq ] when ] lmap>array ;
    
: traverse ( list quot -- newlist )
    [ over list? [ traverse ] [ call ] if ] curry lmap ;
    
INSTANCE: cons list
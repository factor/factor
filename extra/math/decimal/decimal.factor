! Copyright (C) 2013 Loryn Jenkins.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel locals math math.order math.functions combinators ;
IN: math.decimal

: 1/10^ ( p -- f )
    10^ recip ;
    
: decrem ( n p -- r )
    1/10^ rem ; 
    
: decmod ( n p -- m )
    1/10^ mod ;
    
: /decmod ( n p -- q m )
    [ 1/10^ /mod ] keep swap 
    [ 1/10^ * ] dip ;

: truncate* ( n p -- n' )
    /decmod drop ;

<PRIVATE

: incr ( n p -- m )
    dupd [ sgn ] [ 1/10^ ] bi* * + ;

: lsd-odd? ( n p -- ? )
    dup 0 <=> { 
        { +gt+ [ drop numerator odd? ] }
        { +lt+ [ abs 10^ /i odd? ] }
        { +eq+ [ drop odd? ] } 
    } case ;

: msd ( rem p -- d )
    1 + 10^ * 1 /i abs ;
    
: round-half-to-even ( n p -- q' )
    2dup lsd-odd? [ incr ] [ drop ] if ;

PRIVATE>
        
:: round* ( n p -- q )   
    n p /decmod :> ( q r )
    r p msd 5 <=>
    { { +gt+ [ q p incr ] }
      { +lt+ [ q ] }
      { +eq+ [ q p round-half-to-even ] }
    } case ;

USING: math math.order kernel ;

IN: math.compare 

: absmin ( a b -- x ) 
   [ [ abs ] dip abs < ] 2keep ? ;

: absmax ( a b -- x ) 
   [ [ abs ] dip abs > ] 2keep ? ;

: posmax ( a b -- x ) 
   0 max max ;

: negmin ( a b -- x ) 
   0 min min ;

: clamp ( a value b -- x )
   min max ; 


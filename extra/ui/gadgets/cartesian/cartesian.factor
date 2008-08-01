
USING: kernel combinators sequences opengl.gl
       ui.render ui.gadgets ui.gadgets.slate
       accessors ;

IN: ui.gadgets.cartesian

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: cartesian < slate x-min x-max y-min y-max z-min z-max perspective ;

: init-cartesian ( cartesian -- cartesian )
  init-slate
  -10 >>x-min
   10 >>x-max
  -10 >>y-min
   10 >>y-max
   -1 >>z-min
    1 >>z-max ;

: <cartesian> ( -- cartesian ) cartesian new init-cartesian ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: cartesian establish-coordinate-system ( cartesian -- cartesian )
   dup
   {
     [ x-min>> ] [ x-max>> ]
     [ y-min>> ] [ y-max>> ]
     [ z-min>> ] [ z-max>> ]
   }
   cleave
   glOrtho ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: x-range ( cartesian range -- cartesian ) first2 [ >>x-min ] [ >>x-max ] bi* ;
: y-range ( cartesian range -- cartesian ) first2 [ >>y-min ] [ >>y-max ] bi* ;
: z-range ( cartesian range -- cartesian ) first2 [ >>z-min ] [ >>z-max ] bi* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


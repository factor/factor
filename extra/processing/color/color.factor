
USING: kernel sequences ;

IN: processing.color

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: rgba red green blue alpha ;

C: <rgba> rgba

: <rgb> ( r g b -- rgba ) 1 <rgba> ;

: <gray> ( gray -- rgba ) dup dup 1 <rgba> ;

: {rgb} ( seq -- rgba ) first3 <rgb> ;

! : hex>rgba ( hex -- rgba )

! : set-gl-color ( color -- )
!   { [ red>> ] [ green>> ] [ blue>> ] [ alpha>> ] } cleave glColor4d ;


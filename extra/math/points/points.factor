
USING: kernel arrays math.vectors ;

IN: math.points

<PRIVATE

: X ( x -- point )      0   0 3array ;
: Y ( y -- point ) 0 swap   0 3array ;
: Z ( z -- point ) 0    0 rot 3array ;

PRIVATE>

: v+x ( seq x -- seq ) X v+ ;
: v-x ( seq x -- seq ) X v- ;

: v+y ( seq y -- seq ) Y v+ ;
: v-y ( seq y -- seq ) Y v- ;

: v+z ( seq z -- seq ) Z v+ ;
: v-z ( seq z -- seq ) Z v- ;


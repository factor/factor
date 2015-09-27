USING: kernel arrays math.vectors sequences math ;

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

: rise ( pt2 pt1 -- n ) [ second ] bi@ - ;
: run ( pt2 pt1 -- n ) [ first ] bi@ - ;
: slope ( pt pt -- slope ) [ rise ] [ run ] 2bi / ;
: midpoint ( point point -- point ) v+ 2 v/n ;
: linear-solution ( pt pt -- x ) [ drop first2 ] [ slope ] 2bi / - ;

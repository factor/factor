
USING: kernel sequences sorting math math.order macros fry ;

IN: dns.util

: tri-chain ( obj p q r -- x y z )
  [ [ call dup ] dip call dup ] dip call ; inline

MACRO: 1if ( test then else -- ) '[ dup @ _ _ if ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: sort-largest-first ( seq -- seq ) [ [ length ] compare ] sort reverse ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longer? ( seq seq -- ? ) [ length ] bi@ > ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: io.sockets accessors ;

TUPLE: packet data addr socket ;

: receive-packet ( socket -- packet ) [ receive ] keep packet boa ;

: respond ( packet -- ) [ data>> ] [ addr>> ] [ socket>> ] tri send ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: forever ( quot: ( -- ) -- ) [ call ] [ forever ] bi ; inline recursive

USING: kernel sequences sorting math math.order macros fry ;

IN: dns.util

: tri-chain ( obj p q r -- x y z )
  >r >r call dup r> call dup r> call ; inline

MACRO: 1if ( test then else -- ) '[ dup @ , , if ] ;

! : 1if ( test then else -- ) >r >r >r dup r> call r> r> if ; inline ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: sort-largest-first ( seq -- seq ) [ [ length ] compare ] sort reverse ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longer? ( seq seq -- ? ) [ length ] bi@ > ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: io.sockets accessors ;

TUPLE: packet data addr socket ;

: receive-packet ( socket -- packet ) [ receive ] keep packet boa ;

: respond ( packet -- ) [ data>> ] [ addr>> ] [ socket>> ] tri send ;



USING: kernel macros fry ;

IN: dns.util

: tri-chain ( obj p q r -- x y z )
  >r >r call dup r> call dup r> call ; inline

MACRO: 1if ( test then else -- ) '[ dup @ , , if ] ;

! : 1if ( test then else -- ) >r >r >r dup r> call r> r> if ; inline ;
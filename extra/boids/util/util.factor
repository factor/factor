
USING: kernel quotations arrays sequences.private sequences math math.constants
       macros ;

IN: boids.util

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Temporarily defined here until math-contrib gets moved to extra/

: deg>rad pi * 180 / ; inline
: rad>deg 180 * pi / ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: narray ( n -- quot )
    dup [ f <array> ] curry
    swap <reversed> [
        [ swap [ set-nth-unsafe ] keep ] curry
    ] map concat append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: map-call-with ( quots -- )
  [ [ [ keep ] curry ] map concat ] keep length [ nip narray ] curry compose ;

MACRO: map-exec-with ( words -- ) [ 1quotation ] map [ map-call-with ] curry ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: <--&& ( quots -- )
  [ [ 2dup ] swap append [ not ] append [ f ] ] t short-circuit
  [ 2nip ] append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Conceptual implementation:

! : pcall ( seq quots -- seq ) [ call ] 2map ;

MACRO: pcall ( quots -- )

  [ [ unclip ] swap append ] map

  [ [ r> swap add >r ] append ] map

  concat

  [ { } >r ] swap append ! pre

  [ drop r> ] append ;   ! post

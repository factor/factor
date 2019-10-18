
USING: kernel quotations arrays sequences sequences.private macros ;

IN: macros.zoo

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! MACRO: narray ( n -- quot )
!     dup [ f <array> ] curry
!     swap <reversed> [
!         [ swap [ set-nth-unsafe ] keep ] curry
!     ] map concat append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! MACRO: map-call-with ( quots -- )
!   [ [ [ keep ] curry ] map concat ] keep length [ nip narray ] curry compose ;

! MACRO: map-call-with2 ( quots -- )
!   dup >r
!   [ [ 2dup >r >r ] swap append [ r> r> ] append ] map concat
!   [ 2drop ] append
!   r> length [ narray ] curry append ;

! MACRO: map-exec-with ( words -- ) [ 1quotation ] map [ map-call-with ] curry ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Conceptual implementation:

! : pcall ( seq quots -- seq ) [ call ] 2map ;

! MACRO: pcall ( quots -- )
!   [ [ unclip ] swap append ] map
!   [ [ r> swap add >r ] append ] map
!   concat
!   [ { } >r ] swap append ! pre
!   [ drop r> ] append ;   ! post

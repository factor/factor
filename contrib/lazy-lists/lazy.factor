! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel sequences words inference namespaces math parser ;
IN: lazy-lists

: stack-effect-in ( quot word -- n )
  stack-effect dup [ 
    nip effect-in length 
  ] [ 
    drop infer first 
  ] if ;

: make-lazy-quot ( word quot -- quot )
  [
    dup , swap stack-effect-in [ \ curry , ] times \ <promise> , 
  ] [ ] make ;

: LAZY: ( -- object object object )
  CREATE dup reset-generic [ dupd make-lazy-quot define-compound ] f ; parsing

! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: arrays kernel sequences words inference namespaces math
quotations parser ;
IN: lazy-lists

: stack-effect-in ( quot word -- n )
  stack-effect dup [ 
    nip effect-in length 
  ] [ 
    drop infer effect-in length nip
  ] if ;

: make-lazy-quot ( word quot -- quot )
  [
    dup , swap stack-effect-in \ curry <array> % \ <promise> , 
  ] [ ] make ;

: LAZY: ( -- object object object )
  CREATE dup reset-generic
  dup parse-definition
  make-lazy-quot define-compound ; parsing

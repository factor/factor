! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Updated by Matthew Willis, July 2006
! Updated by Chris Double, September 2006

USING: arrays kernel sequences math vectors arrays namespaces
quotations parser effects inference words ;
IN: promises

TUPLE: promise quot forced? value ;

: promise ( quot -- promise )
  f f \ promise construct-boa ;

: promise-with ( value quot -- promise )
  curry promise ;

: promise-with2 ( value1 value2 quot -- promise )
  2curry promise ;

: force ( promise -- value )
    #! Force the given promise leaving the value of calling the
    #! promises quotation on the stack. Re-forcing the promise
    #! will return the same value and not recall the quotation.
    dup promise-forced? [
        dup promise-quot call over set-promise-value
        t over set-promise-forced?
    ] unless
    promise-value ;

: stack-effect-in ( quot word -- n )
  stack-effect [ ] [ infer ] ?if effect-in length ;

: make-lazy-quot ( word quot -- quot )
  [
    dup ,
    swap stack-effect-in \ curry <repetition> % 
    \ promise ,
  ] [ ] make ;

: LAZY:
  CREATE dup reset-generic
  dup parse-definition
  make-lazy-quot define-compound ; parsing

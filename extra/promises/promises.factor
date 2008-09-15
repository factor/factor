! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Updated by Matthew Willis, July 2006
! Updated by Chris Double, September 2006

USING: arrays kernel sequences math vectors arrays namespaces
make quotations parser effects stack-checker words accessors ;
IN: promises

TUPLE: promise quot forced? value ;

: promise ( quot -- promise )
  f f \ promise boa ;

: promise-with ( value quot -- promise )
  curry promise ;

: promise-with2 ( value1 value2 quot -- promise )
  2curry promise ;

: force ( promise -- value )
    #! Force the given promise leaving the value of calling the
    #! promises quotation on the stack. Re-forcing the promise
    #! will return the same value and not recall the quotation.
    dup forced?>> [
        dup quot>> call >>value
        t >>forced?
    ] unless
    value>> ;

: stack-effect-in ( quot word -- n )
  stack-effect [ ] [ infer ] ?if in>> length ;

: make-lazy-quot ( word quot -- quot )
  [
    dup ,
    swap stack-effect-in \ curry <repetition> % 
    \ promise ,
  ] [ ] make ;

: LAZY:
  CREATE-WORD
  dup parse-definition
  make-lazy-quot define ; parsing

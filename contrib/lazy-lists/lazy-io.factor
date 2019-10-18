! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel lazy-lists io ;
IN: lazy-lists

TUPLE: lazy-io stream car cdr quot ;

: lcontents ( stream -- result )
  f f [ stream-read1 ] <lazy-io> ;

: llines ( stream -- result )
  f f [ stream-readln ] <lazy-io> ;

M: lazy-io car ( lazy-io -- car )
  dup lazy-io-car dup [
    nip  
  ] [ 
    drop dup lazy-io-stream over lazy-io-quot call 
    swap dupd set-lazy-io-car
  ] if ;

M: lazy-io cdr ( lazy-io -- cdr )
  dup lazy-io-cdr dup [
    nip
  ] [
    drop dup
    [ lazy-io-stream ] keep
    [ lazy-io-quot ] keep
    car [
      >r f f r> <lazy-io> [ swap set-lazy-io-cdr ] keep
    ] [
      3drop nil
    ] if 
  ] if ;

M: lazy-io nil? ( lazy-io -- bool )
  car not ;

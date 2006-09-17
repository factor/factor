! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel lazy-lists io ;
IN: lazy-lists

TUPLE: lazy-contents stream car cdr ;

: lcontents ( stream -- result )
  f f <lazy-contents> ;

M: lazy-contents car ( lazy-contents -- car )
  dup lazy-contents-car dup [
    nip  
  ] [ 
    drop dup lazy-contents-stream stream-read1 
    swap dupd set-lazy-contents-car
  ] if ;

M: lazy-contents cdr ( lazy-contents -- cdr )
  dup lazy-contents-cdr dup [
    nip
  ] [
    drop dup
    [ lazy-contents-stream ] keep
    car [
      lcontents [ swap set-lazy-contents-cdr ] keep
    ] [
      2drop nil
    ] if 
  ] if ;

M: lazy-contents nil? ( lazy-contents -- bool )
  car not ;
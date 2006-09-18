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

TUPLE: lazy-lines stream car cdr ;

: llines ( stream -- result )
  f f <lazy-lines> ;

M: lazy-lines car ( lazy-lines -- car )
  dup lazy-lines-car dup [
    nip  
  ] [ 
    drop dup lazy-lines-stream stream-readln
    swap dupd set-lazy-lines-car
  ] if ;

M: lazy-lines cdr ( lazy-lines -- cdr )
  dup lazy-lines-cdr dup [
    nip
  ] [
    drop dup
    [ lazy-lines-stream ] keep
    car [
      llines [ swap set-lazy-lines-cdr ] keep
    ] [
      2drop nil
    ] if 
  ] if ;

M: lazy-lines nil? ( lazy-lines -- bool )
  car not ;


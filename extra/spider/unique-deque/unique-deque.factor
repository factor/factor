! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs deques dlists kernel spider ;
IN: spider.unique-deque

TUPLE: todo-url url depth ;

: <todo-url> ( url depth -- todo-url )
    todo-url new
        swap >>depth
        swap >>url ;

TUPLE: unique-deque assoc deque ;

: <unique-deque> ( -- unique-deque )
    H{ } clone <dlist> unique-deque boa ;

: url-exists? ( url unique-deque -- ? )
    [ url>> ] [ assoc>> ] bi* key? ;

: push-url ( url depth unique-deque -- )
    [ <todo-url> ] dip 2dup url-exists? [
        2drop
    ] [
        [ [ [ t ] dip url>> ] [ assoc>> ] bi* set-at ]
        [ deque>> push-back ] 2bi
    ] if ;

: pop-url ( unique-deque -- todo-url ) deque>> pop-front ;

: peek-url ( unique-deque -- todo-url ) deque>> peek-front ;

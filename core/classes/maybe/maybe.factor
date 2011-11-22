! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra
classes.algebra.private classes.private effects generic
kernel sequences words classes.union classes.union.private ;
IN: classes.maybe

TUPLE: maybe { class word initial: object read-only } ;

C: <maybe> maybe

M: maybe instance?
    over [ class>> instance? ] [ 2drop t ] if ;

M: maybe normalize-class
    class>> \ f class-or ;

M: maybe classoid? drop t ;

M: maybe rank-class drop 6 ;

M: maybe (flatten-class)
    class>> (flatten-class) ;

M: maybe effect>type ;

M: maybe method-word-name
    [ class>> name>> ] [ name>> ] bi* "=>" glue ;

M: maybe union-of-builtins?
    class>> union-of-builtins? ;


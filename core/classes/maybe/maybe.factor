! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes classes.algebra
classes.algebra.private classes.private classes.union.private
kernel ;
IN: classes.maybe

TUPLE: maybe { class classoid initial: object read-only } ;

C: <maybe> maybe

INSTANCE: maybe classoid

M: maybe instance?
    over [ class>> instance? ] [ 2drop t ] if ;

: maybe-class-or ( maybe -- classoid )
    class>> \ f class-or ;

M: maybe normalize-class
    maybe-class-or ;

M: maybe rank-class drop 6 ;

M: maybe (flatten-class)
    maybe-class-or (flatten-class) ;

M: maybe union-of-builtins?
    class>> union-of-builtins? ;

M: maybe class-name
    class>> class-name ;

M: maybe predicate-def
    class>> predicate-def [ [ t ] if* ] curry ;

M: maybe contained-classes
    class>> 1array ;

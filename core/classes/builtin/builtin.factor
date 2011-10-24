! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.private classes.algebra
classes.algebra.private words kernel kernel.private namespaces
sequences math math.private combinators assocs quotations ;
IN: classes.builtin

SYMBOL: builtins

PREDICATE: builtin-class < class
    "metaclass" word-prop builtin-class eq? ;

: class>type ( class -- n ) "type" word-prop ; foldable

: type>class ( n -- class ) builtins get-global nth ;

: bootstrap-type>class ( n -- class ) builtins get nth ;

M: object class-of tag type>class ; inline

M: builtin-class rank-class drop 0 ;

M: builtin-class instance? [ tag ] [ class>type ] bi* eq? ;

M: builtin-class (flatten-class) dup set ;

M: builtin-class (classes-intersect?) eq? ;

: full-cover ( -- ) builtins get [ (flatten-class) ] each ;

M: anonymous-complement (flatten-class) drop full-cover ;

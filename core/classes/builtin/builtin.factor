! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: classes classes.algebra.private classes.private kernel
kernel.private make namespaces sequences words ;
IN: classes.builtin

SYMBOL: builtins

PREDICATE: builtin-class < class
    "metaclass" word-prop builtin-class eq? ;

: class>type ( class -- n ) "type" word-prop ; foldable

: type>class ( n -- class ) builtins get-global nth ; foldable

M: object class-of tag type>class ; inline

M: builtin-class rank-class drop 0 ;

M: builtin-class instance? [ tag ] [ class>type ] bi* eq? ;

M: builtin-class (flatten-class) , ;

M: builtin-class (classes-intersect?) eq? ;

: full-cover ( -- ) builtins get [ (flatten-class) ] each ;

M: anonymous-complement (flatten-class) drop full-cover ;

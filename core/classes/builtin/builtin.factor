! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes words kernel kernel.private namespaces
sequences ;
IN: classes.builtin

SYMBOL: builtins

PREDICATE: builtin-class < class
    "metaclass" word-prop builtin-class eq? ;

: type>class ( n -- class ) builtins get-global nth ;

: bootstrap-type>class ( n -- class ) builtins get nth ;

M: hi-tag class hi-tag type>class ;

M: object class tag type>class ;

M: builtin-class rank-class drop 0 ;

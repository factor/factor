! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra words kernel
kernel.private namespaces sequences math math.private
combinators assocs quotations ;
IN: classes.builtin

SYMBOL: builtins

PREDICATE: builtin-class < class
    "metaclass" word-prop builtin-class eq? ;

: class>type ( class -- n ) "type" word-prop ; foldable

PREDICATE: lo-tag-class < builtin-class class>type 7 <= ;

PREDICATE: hi-tag-class < builtin-class class>type 7 > ;

: type>class ( n -- class ) builtins get-global nth ;

: bootstrap-type>class ( n -- class ) builtins get nth ;

M: hi-tag class hi-tag type>class ;

M: object class tag type>class ;

M: builtin-class rank-class drop 0 ;

GENERIC: define-builtin-predicate ( class -- )

M: lo-tag-class define-builtin-predicate
    dup class>type [ eq? ] curry [ tag ] prepend define-predicate ;

M: hi-tag-class define-builtin-predicate
    dup class>type [ eq? ] curry [ hi-tag ] prepend 1quotation
    [ dup tag 6 eq? ] [ [ drop f ] if ] surround
    define-predicate ;

M: lo-tag-class instance? [ tag ] [ class>type ] bi* eq? ;

M: hi-tag-class instance?
    over tag 6 eq? [ [ hi-tag ] [ class>type ] bi* eq? ] [ 2drop f ] if ;

M: builtin-class (flatten-class) dup set ;

M: builtin-class (classes-intersect?)
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over builtin-class? ] [ 2drop f ] }
        [ swap classes-intersect? ]
    } cond ;

M: anonymous-intersection (flatten-class)
    participants>> [ flatten-builtin-class ] map
    [
        builtins get sift [ (flatten-class) ] each
    ] [
        [ ] [ assoc-intersect ] map-reduce [ swap set ] assoc-each
    ] if-empty ;

M: anonymous-complement (flatten-class)
    drop builtins get sift [ (flatten-class) ] each ;

! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra words kernel
kernel.private namespaces sequences math math.private
combinators assocs ;
IN: classes.builtin

SYMBOL: builtins

PREDICATE: builtin-class < class
    "metaclass" word-prop builtin-class eq? ;

: type>class ( n -- class ) builtins get-global nth ;

: class>type ( class -- n ) "type" word-prop ; foldable

: bootstrap-type>class ( n -- class ) builtins get nth ;

M: hi-tag class hi-tag type>class ;

M: object class tag type>class ;

M: builtin-class rank-class drop 0 ;

: builtin-instance? ( object n -- ? )
    #! 7 == tag-mask get
    #! 3 == hi-tag tag-number
    dup 7 fixnum<= [ swap tag eq? ] [
        swap dup tag 3 eq?
        [ hi-tag eq? ] [ 2drop f ] if
    ] if ; inline

M: builtin-class instance?
    class>type builtin-instance? ;

M: builtin-class (flatten-class) dup set ;

M: builtin-class (classes-intersect?)
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over builtin-class? ] [ 2drop f ] }
        [ swap classes-intersect? ]
    } cond ;

M: anonymous-intersection (flatten-class)
    participants>> [ flatten-builtin-class ] map
    dup empty? [
        drop builtins get sift [ (flatten-class) ] each
    ] [
        unclip [ assoc-intersect ] reduce [ swap set ] assoc-each
    ] if ;

M: anonymous-complement (flatten-class)
    drop builtins get sift [ (flatten-class) ] each ;

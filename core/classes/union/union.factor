! Copyright (C) 2004, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences kernel assocs combinators classes
classes.private classes.algebra classes.algebra.private
classes.builtin kernel.private math.private namespaces arrays
math quotations definitions accessors parser effects ;
IN: classes.union

PREDICATE: union-class < class
    "metaclass" word-prop union-class eq? ;

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

<PRIVATE

GENERIC: union-of-builtins? ( class -- ? )

M: builtin-class union-of-builtins? drop t ;

M: union-class union-of-builtins?
    members [ union-of-builtins? ] all? ;

M: maybe union-of-builtins?
    class>> union-of-builtins? ;

M: class union-of-builtins?
    drop f ;

: fast-union-mask ( class -- n )
    [ 0 ] dip flatten-class
    [ drop class>type 2^ bitor ] assoc-each ;

: empty-union-predicate-quot ( class -- quot )
    drop [ drop f ] ;

: fast-union-predicate-quot ( class -- quot )
    fast-union-mask 1quotation
    [ tag 1 swap fixnum-shift-fast ]
    [ fixnum-bitand 0 eq? not ]
    surround ;

: slow-union-predicate-quot ( class -- quot )
    members [ predicate-def ] map unclip swap
    [ [ dup ] prepend [ drop t ] ] { } map>assoc alist>quot ;

: union-predicate-quot ( class -- quot )
    {
        { [ dup members empty? ] [ empty-union-predicate-quot ] }
        { [ dup union-of-builtins? ] [ fast-union-predicate-quot ] }
        [ slow-union-predicate-quot ]
    } cond ;

: define-union-predicate ( class -- )
    dup union-predicate-quot define-predicate ;

M: union-class update-class define-union-predicate ;

: (define-union-class) ( class members -- )
    f swap f union-class make-class-props (define-class) ;

PRIVATE>

: define-union-class ( class members -- )
    [ (define-union-class) ]
    [ drop changed-conditionally ]
    [ drop update-classes ]
    2tri ;

M: union-class rank-class drop 7 ;

M: union-class instance?
    "members" word-prop [ instance? ] with any? ;

M: anonymous-union instance?
    members>> [ instance? ] with any? ;

M: union-class normalize-class
    members <anonymous-union> normalize-class ;

M: union-class (flatten-class)
    members <anonymous-union> (flatten-class) ;


! Copyright (C) 2004, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.algebra
classes.algebra.private classes.builtin classes.private
combinators definitions kernel kernel.private math math.private
quotations sequences words ;
FROM: sets => set= ;
IN: classes.union

PREDICATE: union-class < class
    "metaclass" word-prop union-class eq? ;

<PRIVATE

GENERIC: union-of-builtins? ( class -- ? )

M: builtin-class union-of-builtins? drop t ;

M: union-class union-of-builtins?
    members [ union-of-builtins? ] all? ;

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

ERROR: cannot-reference-self class members ;

GENERIC: classes-contained-by ( obj -- members )

M: union-class classes-contained-by ( union -- members )
    "members" word-prop [ f ] when-empty ;

M: object classes-contained-by
    "members" word-prop [ f ] when-empty ;

: check-self-reference ( class members -- class members )
    2dup [
        dup dup [ classes-contained-by ] map concat sift append
        2dup set= [ 2drop f ] [ nip ] if
    ] follow concat
    member-eq? [ cannot-reference-self ] when ;

PRIVATE>

: define-union-class ( class members -- )
    [ check-self-reference (define-union-class) ]
    [ drop changed-conditionally ]
    [ drop update-classes ]
    2tri ;

M: union-class rank-class drop 7 ;

M: union-class instance?
    "members" word-prop [ instance? ] with any? ;

M: anonymous-union instance?
    members>> [ instance? ] with any? ;

M: anonymous-union class-name
    members>> [ class-name ] map " " join ;

M: union-class normalize-class
    members <anonymous-union> normalize-class ;

M: union-class (flatten-class)
    members <anonymous-union> (flatten-class) ;

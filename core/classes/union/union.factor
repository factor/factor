! Copyright (C) 2004, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.algebra
classes.algebra.private classes.builtin classes.private
classes.tuple classes.tuple.private combinators definitions
kernel kernel.private math math.private quotations sequences
slots.private sorting splitting words ;
IN: classes.union

PREDICATE: union-class < class
    "metaclass" word-prop union-class eq? ;

<PRIVATE

GENERIC: union-of-builtins? ( class -- ? )

M: builtin-class union-of-builtins? drop t ;

M: union-class union-of-builtins?
    class-members [ union-of-builtins? ] all? ;

M: class union-of-builtins?
    drop f ;

: empty-union-predicate-quot ( class-members -- quot )
    drop [ drop f ] ;

: flatten-builtins ( builtin-classes -- seq )
    [ flatten-class ] map concat ;

: builtin-union-mask ( builtin-classes -- n )
    0 [ class>type 2^ bitor ] reduce ;

: builtin-union-predicate-quot ( builtin-classes -- quot )
    flatten-builtins dup length 1 = [
        first class>type [ eq? ] curry [ tag ] prepose
    ] [
        builtin-union-mask 1quotation
        [ tag 1 swap fixnum-shift-fast ]
        [ fixnum-bitand 0 eq? not ]
        surround
    ] if ;

: predicate-quot ( predicates -- quot )
    unclip swap
    [ [ dup ] prepend [ drop t ] ] { } map>assoc alist>quot ;

! this replicates logic in classes.tuple, keep in sync
: tuple-union-predicate-quot/1 ( tuple-classes -- quot )
    [ [ eq? ] curry ] map predicate-quot
    [ 7 slot ] prepose ;

: tuple-union-predicate-quot/n ( echelon tuple-classes -- quot )
    [ layout-class-offset ] dip
    [ [ eq? ] curry ] map predicate-quot
    over [ slot ] curry prepose [ drop f ] [ if ] 2curry
    swap [ fixnum>= ] curry [ dup 1 slot ] prepose prepose ;

: tuple-union-predicate-quot ( tuple-classes -- quot )
    [ echelon-of 1 = ] partition
    [ [ f ] [ tuple-union-predicate-quot/1 ] if-empty ] dip
    [ echelon-of ] collect-by sort-keys
    [ tuple-union-predicate-quot/n ] { } assoc>map
    swap [ suffix ] when* predicate-quot
    [ layout-of ] prepose [ drop f ] [ if ] 2curry
    [ dup tuple? ] prepose ;

: full-union-predicate-quot ( class-members -- quot )
    [ union-of-builtins? ] partition
    [ [ f ] [ builtin-union-predicate-quot ] if-empty ] dip
    [ [ tuple-class? ] [ tuple-layout ] bi and ] partition
    [ [ f ] [ tuple-union-predicate-quot ] if-empty ] dip
    [ predicate-def ] map
    swap [ suffix ] when*
    swap [ suffix ] when*
    predicate-quot ;

: union-predicate-quot ( class-members -- quot )
    {
        { [ dup empty? ] [ empty-union-predicate-quot ] }
        { [ dup [ union-of-builtins? ] all? ] [ builtin-union-predicate-quot ] }
        [ full-union-predicate-quot ]
    } cond ;

: define-union-predicate ( class -- )
    dup class-members union-predicate-quot define-predicate ;

M: union-class update-class define-union-predicate ;

ERROR: cannot-reference-self class members ;

: check-self-reference ( class members -- class members )
    2dup all-contained-classes member-eq? [ cannot-reference-self ] when ;

: (define-union-class) ( class members -- )
    check-self-reference f swap f union-class make-class-props (define-class) ;

PRIVATE>

: define-union-class ( class members -- )
    [ (define-union-class) ]
    [ drop changed-conditionally ]
    [ drop update-classes ]
    2tri ;

M: union-class rank-class drop 7 ;

M: union-class instance?
    "members" word-prop [ instance? ] with any? ;

M: anonymous-union predicate-def
    members>> union-predicate-quot ;

M: anonymous-union instance?
    members>> [ instance? ] with any? ;

M: anonymous-union class-name
    members>> [ class-name ] map join-words ;

M: union-class normalize-class
    class-members <anonymous-union> normalize-class ;

M: union-class (flatten-class)
    class-members <anonymous-union> (flatten-class) ;

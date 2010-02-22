! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes classes.private classes.algebra
classes.algebra.private classes.union classes.union.private
words kernel sequences definitions combinators arrays assocs
generic accessors ;
IN: classes.mixin

PREDICATE: mixin-class < union-class "mixin" word-prop ;

M: mixin-class normalize-class ;

M: mixin-class (classes-intersect?)
    members [ classes-intersect? ] with any? ;

M: mixin-class reset-class
    [ call-next-method ] [ { "mixin" } reset-props ] bi ;

M: mixin-class rank-class drop 3 ;

TUPLE: check-mixin-class class ;

: check-mixin-class ( mixin -- mixin )
    dup mixin-class? [
        \ check-mixin-class boa throw
    ] unless ;

<PRIVATE

: redefine-mixin-class ( class members -- )
    [ (define-union-class) ]
    [ drop changed-conditionally ]
    [ drop t "mixin" set-word-prop ]
    2tri ;

: if-mixin-member? ( class mixin true false -- )
    [ check-mixin-class 2dup members member-eq? ] 2dip if ; inline

: change-mixin-class ( class mixin quot -- )
    [ [ members swap bootstrap-word ] dip call ] [ drop ] 2bi
    swap redefine-mixin-class ; inline

: (add-mixin-instance) ( class mixin -- )
    #! Call update-methods before adding the member:
    #! - Call sites of generics specializing on 'mixin'
    #! where the inferred type is 'class' are updated,
    #! - Call sites where the inferred type is a subtype
    #! of 'mixin' disjoint from 'class' are not updated
    dup class-usages {
        [ nip update-methods ]
        [ drop [ suffix ] change-mixin-class ]
        [ drop [ f ] 2dip "instances" word-prop set-at ]
        [ 2nip [ update-class ] each ]
    } 3cleave ;

: (remove-mixin-instance) ( class mixin -- )
    #! Call update-methods after removing the member:
    #! - Call sites of generics specializing on 'mixin'
    #! where the inferred type is 'class' are updated,
    #! - Call sites where the inferred type is a subtype
    #! of 'mixin' disjoint from 'class' are not updated
    dup class-usages {
        [ drop [ swap remove ] change-mixin-class ]
        [ drop "instances" word-prop delete-at ]
        [ 2nip [ update-class ] each ]
        [ nip update-methods ]
    } 3cleave ;

PRIVATE>

GENERIC# add-mixin-instance 1 ( class mixin -- )

M: class add-mixin-instance
    [ 2drop ] [ (add-mixin-instance) ] if-mixin-member? ;

: remove-mixin-instance ( class mixin -- )
    [ (remove-mixin-instance) ] [ 2drop ] if-mixin-member? ;

M: mixin-class metaclass-changed
    over class? [ 2drop ] [ remove-mixin-instance ] if ;

: define-mixin-class ( class -- )
    dup mixin-class? [
        drop
    ] [
        [ { } redefine-mixin-class ]
        [ H{ } clone "instances" set-word-prop ]
        [ update-classes ]
        tri
    ] if ;

! Definition protocol implementation ensures that removing an
! INSTANCE: declaration from a source file updates the mixin.
TUPLE: mixin-instance class mixin ;

C: <mixin-instance> mixin-instance

<PRIVATE

: >mixin-instance< ( mixin-instance -- class mixin )
    [ class>> ] [ mixin>> ] bi ; inline

PRIVATE>

M: mixin-instance where >mixin-instance< "instances" word-prop at ;

M: mixin-instance set-where >mixin-instance< "instances" word-prop set-at ;

M: mixin-instance definer drop \ INSTANCE: f ;

M: mixin-instance definition drop f ;

M: mixin-instance forget*
    >mixin-instance<
    dup mixin-class? [ remove-mixin-instance ] [ 2drop ] if ;

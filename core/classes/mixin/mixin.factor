! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes classes.union words kernel sequences
definitions combinators arrays assocs generic accessors ;
IN: classes.mixin

PREDICATE: mixin-class < union-class "mixin" word-prop ;

M: mixin-class reset-class
    [ call-next-method ] [ { "mixin" } reset-props ] bi ;

M: mixin-class rank-class drop 3 ;

: redefine-mixin-class ( class members -- )
    [ (define-union-class) ]
    [ drop t "mixin" set-word-prop ]
    2bi ;

: define-mixin-class ( class -- )
    dup mixin-class? [
        drop
    ] [
        [ { } redefine-mixin-class ]
        [ H{ } clone "instances" set-word-prop ]
        [ update-classes ]
        tri
    ] if ;

TUPLE: check-mixin-class class ;

: check-mixin-class ( mixin -- mixin )
    dup mixin-class? [
        \ check-mixin-class boa throw
    ] unless ;

: if-mixin-member? ( class mixin true false -- )
    [ check-mixin-class 2dup members memq? ] 2dip if ; inline

: change-mixin-class ( class mixin quot -- )
    [ [ members swap bootstrap-word ] dip call ] [ drop ] 2bi
    swap redefine-mixin-class ; inline

: update-classes/new ( mixin -- )
    class-usages
    [ [ update-class ] each ]
    [ implementors [ remake-generic ] each ] bi ;

: (add-mixin-instance) ( class mixin -- )
    [ [ suffix ] change-mixin-class ]
    [ [ f ] 2dip "instances" word-prop set-at ]
    2bi ;

GENERIC# add-mixin-instance 1 ( class mixin -- )

M: class add-mixin-instance
    #! Note: we call update-classes on the new member, not the
    #! mixin. This ensures that we only have to update the
    #! methods whose specializer intersects the new member, not
    #! the entire mixin (since the other mixin members are not
    #! affected at all). Also, all usages of the mixin will get
    #! updated by transitivity; the mixins usages appear in
    #! class-usages of the member, now that it's been added.
    [ 2drop ] [
        [ (add-mixin-instance) ] 2keep
        [ nip ] [ [ new-class? ] either? ] 2bi
        [ update-classes/new ] [ update-classes ] if
    ] if-mixin-member? ;

: (remove-mixin-instance) ( class mixin -- )
    [ [ swap remove ] change-mixin-class ]
    [ "instances" word-prop delete-at ]
    2bi ;

: remove-mixin-instance ( class mixin -- )
    #! The order of the three clauses is important here. The last
    #! one must come after the other two so that the entries it
    #! adds to changed-generics are not overwritten.
    [
        [ (remove-mixin-instance) ]
        [ nip update-classes ]
        [ class-usages update-methods ]
        2tri
    ] [ 2drop ] if-mixin-member? ;

M: mixin-class class-forgotten remove-mixin-instance ;

! Definition protocol implementation ensures that removing an
! INSTANCE: declaration from a source file updates the mixin.
TUPLE: mixin-instance class mixin ;

C: <mixin-instance> mixin-instance

: >mixin-instance< ( mixin-instance -- class mixin )
    [ class>> ] [ mixin>> ] bi ; inline

M: mixin-instance where >mixin-instance< "instances" word-prop at ;

M: mixin-instance set-where >mixin-instance< "instances" word-prop set-at ;

M: mixin-instance definer drop \ INSTANCE: f ;

M: mixin-instance definition drop f ;

M: mixin-instance forget*
    >mixin-instance<
    dup mixin-class? [ remove-mixin-instance ] [ 2drop ] if ;

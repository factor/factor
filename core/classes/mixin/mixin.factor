! Copyright (C) 2004, 2008 Slava Pestov.
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
        [ update-classes ]
        bi
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

: add-mixin-instance ( class mixin -- )
    #! Note: we call update-classes on the new member, not the
    #! mixin. This ensures that we only have to update the
    #! methods whose specializer intersects the new member, not
    #! the entire mixin (since the other mixin members are not
    #! affected at all). Also, all usages of the mixin will get
    #! updated by transitivity; the mixins usages appear in
    #! class-usages of the member, now that it's been added.
    [ 2drop ] [
        [ [ suffix ] change-mixin-class ] 2keep
        [ nip ] [ [ new-class? ] either? ] 2bi [
            update-classes/new
        ] [
            update-classes
        ] if
    ] if-mixin-member? ;

: remove-mixin-instance ( class mixin -- )
    #! The order of the three clauses is important here. The last
    #! one must come after the other two so that the entries it
    #! adds to changed-generics are not overwritten.
    [
        [ [ swap remove ] change-mixin-class ]
        [ nip update-classes ]
        [ class-usages update-methods ]
        2tri
    ] [ 2drop ] if-mixin-member? ;

M: mixin-class class-forgotten remove-mixin-instance ;

! Definition protocol implementation ensures that removing an
! INSTANCE: declaration from a source file updates the mixin.
TUPLE: mixin-instance loc class mixin ;

M: mixin-instance equal?
    {
        { [ over mixin-instance? not ] [ f ] }
        { [ 2dup [ class>> ] bi@ = not ] [ f ] }
        { [ 2dup [ mixin>> ] bi@ = not ] [ f ] }
        [ t ]
    } cond 2nip ;

M: mixin-instance hashcode*
    [ class>> ] [ mixin>> ] bi 2array hashcode* ;

: <mixin-instance> ( class mixin -- definition )
    mixin-instance new
        swap >>mixin
        swap >>class ;

M: mixin-instance where loc>> ;

M: mixin-instance set-where (>>loc) ;

M: mixin-instance definer drop \ INSTANCE: f ;

M: mixin-instance definition drop f ;

M: mixin-instance forget*
    [ class>> ] [ mixin>> ] bi
    dup mixin-class? [ remove-mixin-instance ] [ 2drop ] if ;

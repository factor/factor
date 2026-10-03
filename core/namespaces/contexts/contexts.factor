! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel kernel.private math
sequences vectors ;
IN: namespaces.contexts

! Scope topology is private to a context; frames and values are shared by
! captures. A shared clock invalidates indexes when a frame gains a key or
! exposes its mutable assoc. Updating an existing cell needs no invalidation.
TUPLE: namespace-clock { revision integer } ;
TUPLE: namespace-frame
    values { bindings vector } { depth integer } borrowed? shared? ;
TUPLE: namespace-binding key value { owner namespace-frame } ;
TUPLE: namespace-context
    globals { scopes vector }
    { index maybe{ hashtable } } { borrowed maybe{ vector } }
    { clock namespace-clock } { revision integer } index-shared? ;

: <namespace-context> ( globals -- context )
    V{ } clone H{ } clone V{ } clone
    0 namespace-clock boa 0 f namespace-context boa ;

<PRIVATE

: index-binding ( binding context -- )
    index>> [ dup key>> ] dip push-at ;

: push-index-binding ( binding context -- )
    index>> [ dup key>> ] dip 2dup at
    [ clone ] [ V{ } clone ] if* [ rot ] dip
    [ push ] keep -rot set-at ;

: index-frame ( frame context -- )
    over borrowed?>> [ borrowed>> push ] [
        [ bindings>> ] dip '[ _ index-binding ] each
    ] if ;

: rebuild-index ( context -- )
    H{ } clone >>index V{ } clone >>borrowed
    dup scopes>> [ over index-frame ] each
    dup clock>> revision>> >>revision f >>index-shared? drop ;

: check-index ( context -- context )
    { namespace-context } declare
    dup index>> [
        dup [ revision>> ] [ clock>> revision>> ] bi eq?
        [ dup rebuild-index ] unless
    ] [ dup rebuild-index ] if ; inline

: bump-clock ( context -- )
    clock>> [ 1 + ] change-revision drop ;

: writable-index ( context -- context )
    dup index-shared?>> [
        dup index>> clone >>index f >>index-shared?
    ] when ;

: binding-at ( key context -- binding/f )
    index>> { hashtable } declare at [
        { vector } declare last { namespace-binding } declare
    ] [ f ] if* ; inline

: binding-depth ( binding/f -- depth )
    [ owner>> depth>> ] [ -1 ] if* ; inline

: key-in-frame? ( key binding/f frame -- key binding/f ? )
    dup depth>> pick binding-depth > [
        values>> [ over ] dip key?
    ] [ drop f ] if ;

: borrowed-get* ( key context -- value bound? )
    [ dupd binding-at ] [ borrowed>> ] bi
    [ key-in-frame? ] find-last nip [
        [ drop ] dip values>> at t
    ] [
        [ nip value>> t ] [ drop f f ] if*
    ] if* ;

: clear-frame-bindings ( frame -- )
    bindings>> dup [ f swap value<< ] each delete-all ;

: materialize-frame ( frame context -- assoc )
    over borrowed?>> [ drop values>> ] [
        over [ bindings>> [ [ key>> ] [ value>> ] bi ] H{ } map>assoc ] keep
        swap >>values t >>borrowed? drop
        over clear-frame-bindings
        bump-clock values>>
    ] if ;

: add-binding ( value key frame context -- )
    [ [ swap ] dip namespace-binding boa ] dip
    [ push-index-binding ] 2keep drop
    dup owner>> bindings>> push ;

: unindex-binding ( binding context -- removed? )
    [ dup key>> ] dip index>> { hashtable } declare 2dup at [
        { vector } declare
        ! Mutable keys can change hash or become equal to another key.
        ! Only remove a vector whose top cell is the binding being popped.
        dup last [ reach ] dip eq? [
            dup length 1 = [ drop delete-at ] [
                clone dup pop* -rot set-at
            ] if drop t
        ] [ 4drop f ] if
    ] [ 3drop f ] if* ;

PRIVATE>

! Keep guards and fallback branches out of every caller's compiler IR.
! Cache rebuilding is internal; a discarded read may be eliminated.
: context-get ( key context -- value )
    check-index dup borrowed>> empty? [
        2dup binding-at [ 2nip value>> ] [ globals>> at ] if*
    ] [
        2dup borrowed-get* [ 2nip ] [ drop globals>> at ] if
    ] if ; flushable

: context-set ( value key context -- )
    check-index dup scopes>> empty? [
        globals>> dup [ set-at ] [ drop V{ } last set-at ] if
    ] [
        dup scopes>> last dup borrowed?>> [
            nip values>> set-at
        ] [
            [ 2dup binding-at dup [ owner>> ] [ f ] if* ] dip eq? [
                [ 2drop ] dip value<<
            ] [
                drop writable-index
                dup scopes>> last swap over shared?>>
                [ dup bump-clock ] when
                [ add-binding ] keep
                dup clock>> revision>> >>revision drop
            ] if
        ] if
    ] if ;

: context-push ( assoc/f borrowed? context -- )
    check-index [ scopes>> length ] keep
    [ swap [ V{ } clone ] 2dip f namespace-frame boa ] dip
    [ scopes>> push ] 2keep index-frame ;

: context-push-scope ( context -- )
    [ f f ] dip context-push ;

: context-push-variables ( assoc context -- )
    [ t ] dip context-push ;

: context-pop ( context -- )
    check-index dup scopes>> pop dup borrowed?>> [
        swap borrowed>> remove-eq! drop
    ] [
        swap [ bindings>> ] dip writable-index
        [ '[ _ unindex-binding ] all? ] keep
        swap [ drop ] [ rebuild-index ] if
    ] if ;

: context-namespace ( context -- assoc )
    dup scopes>> empty? [
        globals>> dup [ ] [ drop V{ } last ] if
    ] [
        dup scopes>> last swap materialize-frame
    ] if ;

: context-snapshot ( context -- snapshot )
    dup scopes>> [ t >>shared? drop ] each
    t >>index-shared? clone dup scopes>> clone >>scopes
    dup borrowed>> clone >>borrowed ;

: context>namestack ( context -- vector )
    dup scopes>> [ over materialize-frame ] map >vector
    swap globals>> [ prefix >vector ] when* ;

: namestack>context ( namestack globals -- context )
    over empty? [ drop f ] [
        over first over eq? [ [ rest ] dip ] [ drop f ] if
    ] if
    <namespace-context> swap [ over context-push-variables ] each ;

! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators definitions generic
generic.single generic.single.private kernel layouts make math
namespaces quotations sequences words ;
IN: generic.standard

ERROR: bad-dispatch-position n ;

TUPLE: standard-combination < single-combination n ;

: <standard-combination> ( # -- standard-combination )
    dup integer? [ dup 0 < ] [ t ] if
    [ bad-dispatch-position ] when
    standard-combination boa ;

M: standard-combination check-combination-effect
    [ dispatch-number ] [ in>> length ] bi* over >
    [ drop ] [ bad-dispatch-position ] if ;

PREDICATE: standard-generic < generic
    "combination" word-prop standard-combination? ;

PREDICATE: simple-generic < standard-generic
    "combination" word-prop n>> 0 = ;

CONSTANT: simple-combination T{ standard-combination f 0 }

: define-simple-generic ( word effect -- )
    [ simple-combination ] dip define-generic ;

: (picker) ( n -- quot )
    {
        { 0 [ [ dup ] ] }
        { 1 [ [ over ] ] }
        { 2 [ [ pick ] ] }
        [ 1 - (picker) [ dip swap ] curry ]
    } case ;

M: standard-combination picker
    combination get n>> (picker) ;

M: standard-combination dispatch-number n>> ;

M: standard-generic effective-method
    [ get-datastack ] dip [ "combination" word-prop n>> swap <reversed> nth ] keep
    method-for-object ;

: inline-cache-quot ( word methods miss-word -- quot )
    [ [ literalize , ] [ , ] [ combination get n>> , { } , , ] tri* ] [ ] make ;

M: standard-combination inline-cache-quots
    ! Direct calls to the generic word (not tail calls or indirect calls)
    ! will jump to the inline cache entry point instead of the megamorphic
    ! dispatch entry point.
    [ \ inline-cache-miss inline-cache-quot ]
    [ \ inline-cache-miss-tail inline-cache-quot ]
    2bi ;

: make-empty-cache ( -- array )
    mega-cache-size get f <array> ;

M: standard-combination mega-cache-quot
    combination get n>> make-empty-cache \ mega-cache-lookup [ ] 4sequence ;

M: standard-generic definer drop \ GENERIC#: f ;

M: simple-generic definer drop \ GENERIC: f ;

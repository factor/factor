! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors definitions generic generic.single kernel
namespaces words math math.order combinators sequences
generic.single.private quotations kernel.private
assocs arrays layouts make ;
IN: generic.standard

ERROR: bad-dispatch-position # ;

TUPLE: standard-combination < single-combination # ;

: <standard-combination> ( # -- standard-combination )
    dup 0 < [ bad-dispatch-position ] when
    standard-combination boa ;

PREDICATE: standard-generic < generic
    "combination" word-prop standard-combination? ;

PREDICATE: simple-generic < standard-generic
    "combination" word-prop #>> 0 = ;

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
    combination get #>> (picker) ;

M: standard-combination dispatch# #>> ;

M: standard-generic effective-method
    [ datastack ] dip [ "combination" word-prop #>> swap <reversed> nth ] keep
    (effective-method) ;

: inline-cache-quot ( word methods miss-word -- quot )
    [ [ literalize , ] [ , ] [ combination get #>> , { } , , ] tri* ] [ ] make ;

M: standard-combination inline-cache-quots
    #! Direct calls to the generic word (not tail calls or indirect calls)
    #! will jump to the inline cache entry point instead of the megamorphic
    #! dispatch entry point.
    [ \ inline-cache-miss inline-cache-quot ]
    [ \ inline-cache-miss-tail inline-cache-quot ]
    2bi ;

: make-empty-cache ( -- array )
    mega-cache-size get f <array> ;

M: standard-combination mega-cache-quot
    combination get #>> make-empty-cache \ mega-cache-lookup [ ] 4sequence ;

M: standard-generic definer drop \ GENERIC# f ;

M: simple-generic definer drop \ GENERIC: f ;

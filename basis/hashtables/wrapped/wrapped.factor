! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs hashtables kernel sequences
vocabs.loader ;

IN: hashtables.wrapped

TUPLE: wrapped-key
    { underlying read-only } ;

TUPLE: wrapped-hashtable
    { underlying hashtable read-only } ;

GENERIC: wrap-key ( key wrapped-hash -- wrapped-key )

<PRIVATE

: wrapper@ ( key wrapped-hash -- wrapped-key hash )
    [ wrap-key ] [ nip underlying>> ] 2bi ; inline

PRIVATE>

M: wrapped-hashtable at*
    wrapper@ at* ; inline

M: wrapped-hashtable clear-assoc
    underlying>> clear-assoc ; inline

M: wrapped-hashtable delete-at
    wrapper@ delete-at ; inline

M: wrapped-hashtable assoc-size
    underlying>> assoc-size ; inline

M: wrapped-hashtable set-at
    wrapper@ set-at ; inline

M: wrapped-hashtable >alist
    underlying>> >alist [ [ first underlying>> ] [ second ] bi 2array ] map ;

M: wrapped-hashtable equal?
    over wrapped-hashtable? [ [ underlying>> ] bi@ = ] [ 2drop f ] if ;

INSTANCE: wrapped-hashtable assoc

{ "hashtables.wrapped" "prettyprint" } "hashtables.wrapped.prettyprint" require-when

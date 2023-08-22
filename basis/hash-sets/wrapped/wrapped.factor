! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays hash-sets kernel sequences sets
vocabs.loader ;

IN: hash-sets.wrapped

TUPLE: wrapped-hash-set
    { underlying hash-set read-only } ;

GENERIC: wrap-key ( key wrapped-hash -- wrapped-key )

<PRIVATE

: wrapper@ ( key wrapped-hash -- wrapped-key hash-set )
    [ wrap-key ] [ nip underlying>> ] 2bi ; inline

PRIVATE>

M: wrapped-hash-set adjoin
    wrapper@ adjoin ; inline

M: wrapped-hash-set ?adjoin
    wrapper@ ?adjoin ; inline

M: wrapped-hash-set in?
    wrapper@ in? ; inline

M: wrapped-hash-set clear-set
    underlying>> clear-set ; inline

M: wrapped-hash-set delete
    wrapper@ delete ; inline

M: wrapped-hash-set ?delete
    wrapper@ ?delete ; inline

M: wrapped-hash-set cardinality
    underlying>> cardinality ; inline

M: wrapped-hash-set members
    underlying>> members [ underlying>> ] map! ;

M: wrapped-hash-set equal?
    over wrapped-hash-set? [ [ underlying>> ] same? ] [ 2drop f ] if ;

INSTANCE: wrapped-hash-set set

{ "hash-sets.wrapped" "prettyprint" } "hash-sets.wrapped.prettyprint" require-when

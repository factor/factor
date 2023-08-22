! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors hash-sets hash-sets.wrapped kernel math parser
sequences vocabs.loader ;

IN: hash-sets.sequences

<PRIVATE

TUPLE: sequence-wrapper
    { underlying sequence read-only } ;

C: <sequence-wrapper> sequence-wrapper

M: sequence-wrapper equal?
    over sequence-wrapper?
    [ [ underlying>> ] bi@ sequence= ]
    [ 2drop f ] if ; inline

M: sequence-wrapper hashcode*
    underlying>> [ sequence-hashcode ] recursive-hashcode ; inline

PRIVATE>

TUPLE: sequence-hash-set < wrapped-hash-set ;

: <sequence-hash-set> ( n -- shash-set )
    <hash-set> sequence-hash-set boa ; inline

M: sequence-hash-set wrap-key drop <sequence-wrapper> ;

M: sequence-hash-set clone
    underlying>> clone sequence-hash-set boa ; inline

: >sequence-hash-set ( members -- shash-set )
    [ <sequence-wrapper> ] map >hash-set sequence-hash-set boa ;

SYNTAX: SHS{ \ } [ >sequence-hash-set ] parse-literal ;

{ "hash-sets.sequences" "prettyprint" } "hash-sets.sequences.prettyprint" require-when

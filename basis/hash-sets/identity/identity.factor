! Copyright (C) 2013 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors hash-sets hash-sets.wrapped kernel parser
sequences sets sets.private vocabs.loader ;
IN: hash-sets.identity

<PRIVATE

TUPLE: identity-wrapper
    { underlying read-only } identity-hashcode ;

: <identity-wrapper> ( wrapped-key -- identity-wrapper )
    dup identity-hashcode identity-wrapper boa ; inline

M: identity-wrapper equal?
    over identity-wrapper?
    [ [ underlying>> ] bi@ eq? ]
    [ 2drop f ] if ; inline

M: identity-wrapper hashcode* nip identity-hashcode>> ; inline

PRIVATE>

TUPLE: identity-hash-set < wrapped-hash-set ;

: <identity-hash-set> ( n -- ihash-set )
    <hash-set> identity-hash-set boa ; inline

M: identity-hash-set wrap-key drop <identity-wrapper> ;

M: identity-hash-set clone
    underlying>> clone identity-hash-set boa ; inline

: >identity-hash-set ( members -- ihash-set )
    [ <identity-wrapper> ] map >hash-set identity-hash-set boa ; inline

M: identity-hash-set set-like
    drop dup identity-hash-set? [ ?members >identity-hash-set ] unless ; inline

SYNTAX: IHS{ \ } [ >identity-hash-set ] parse-literal ;

{ "hash-sets.identity" "prettyprint" } "hash-sets.identity.prettyprint" require-when

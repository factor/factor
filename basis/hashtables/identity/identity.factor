! Copyright (C) 2010 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables hashtables.wrapped kernel
parser vocabs.loader ;
IN: hashtables.identity

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

TUPLE: identity-hashtable < wrapped-hashtable ;

: <identity-hashtable> ( n -- ihashtable )
    <hashtable> identity-hashtable boa ; inline

M: identity-hashtable wrap-key drop <identity-wrapper> ;

M: identity-hashtable clone
    underlying>> clone identity-hashtable boa ; inline

: identity-associate ( value key -- ihashtable )
    2 <identity-hashtable> [ set-at ] keep ; inline

: >identity-hashtable ( assoc -- ihashtable )
    [ assoc-size <identity-hashtable> ] keep assoc-union! ;

M: identity-hashtable assoc-like
    drop dup identity-hashtable? [ >identity-hashtable ] unless ; inline

M: identity-hashtable new-assoc drop <identity-hashtable> ;

SYNTAX: IH{ \ } [ >identity-hashtable ] parse-literal ;

{ "hashtables.identity" "prettyprint" } "hashtables.identity.prettyprint" require-when
{ "hashtables.identity" "mirrors" } "hashtables.identity.mirrors" require-when

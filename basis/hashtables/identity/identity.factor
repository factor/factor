! (c)2010 Joe Groff bsd license
USING: accessors assocs hashtables hashtables.wrapped kernel
parser vocabs.loader ;
IN: hashtables.identity

TUPLE: identity-wrapper < wrapped-key ;

C: <identity-wrapper> identity-wrapper

M: identity-wrapper equal?
    over identity-wrapper?
    [ [ underlying>> ] bi@ eq? ]
    [ 2drop f ] if ; inline

M: identity-wrapper hashcode*
    nip underlying>> identity-hashcode ; inline

TUPLE: identity-hashtable < wrapped-hashtable ;

: <identity-hashtable> ( n -- ihash )
    <hashtable> identity-hashtable boa ; inline

M: identity-hashtable wrap-key drop <identity-wrapper> ;

M: identity-hashtable clone
    underlying>> clone identity-hashtable boa ; inline

: identity-associate ( value key -- hash )
    2 <identity-hashtable> [ set-at ] keep ; inline

: >identity-hashtable ( assoc -- ihashtable )
    [ assoc-size <identity-hashtable> ] keep assoc-union! ;

M: identity-hashtable assoc-like
    drop dup identity-hashtable? [ >identity-hashtable ] unless ; inline

M: identity-hashtable new-assoc drop <identity-hashtable> ;

SYNTAX: IH{ \ } [ >identity-hashtable ] parse-literal ;

{ "hashtables.identity" "prettyprint" } "hashtables.identity.prettyprint" require-when
{ "hashtables.identity" "mirrors" } "hashtables.identity.mirrors" require-when

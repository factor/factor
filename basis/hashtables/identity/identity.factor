! (c)2010 Joe Groff bsd license
USING: accessors arrays assocs fry hashtables kernel parser
sequences vocabs.loader ;
IN: hashtables.identity

TUPLE: identity-wrapper
    { underlying read-only } ;
C: <identity-wrapper> identity-wrapper

M: identity-wrapper equal?
    over identity-wrapper?
    [ [ underlying>> ] bi@ eq? ]
    [ 2drop f ] if ; inline

M: identity-wrapper hashcode*
    nip underlying>> identity-hashcode ; inline

TUPLE: identity-hashtable
    { underlying hashtable read-only } ;

: <identity-hashtable> ( n -- ihash )
    <hashtable> identity-hashtable boa ; inline

<PRIVATE
: identity@ ( key ihash -- ikey hash )
    [ <identity-wrapper> ] [ underlying>> ] bi* ; inline
PRIVATE>

M: identity-hashtable at*
    identity@ at* ; inline

M: identity-hashtable clear-assoc
    underlying>> clear-assoc ; inline

M: identity-hashtable delete-at
    identity@ delete-at ; inline

M: identity-hashtable assoc-size
    underlying>> assoc-size ; inline

M: identity-hashtable set-at
    identity@ set-at ; inline

: identity-associate ( value key -- hash )
    2 <identity-hashtable> [ set-at ] keep ; inline

M: identity-hashtable >alist
    underlying>> >alist [ [ first underlying>> ] [ second ] bi 2array ] map ;
    
M: identity-hashtable clone
    underlying>> clone identity-hashtable boa ; inline

M: identity-hashtable equal?
    over identity-hashtable? [ [ underlying>> ] bi@ = ] [ 2drop f ] if ;

: >identity-hashtable ( assoc -- ihashtable )
    dup assoc-size <identity-hashtable> [ '[ swap _ set-at ] assoc-each ] keep ;

SYNTAX: IH{ \ } [ >identity-hashtable ] parse-literal ;

{ "hashtables.identity" "prettyprint" } "hashtables.identity.prettyprint" require-when
{ "hashtables.identity" "mirrors" } "hashtables.identity.mirrors" require-when

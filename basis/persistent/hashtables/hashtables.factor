! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: accessors assocs combinators kernel make math
parser persistent.assocs persistent.hashtables.nodes
prettyprint.custom ;

IN: persistent.hashtables

TUPLE: persistent-hash
    { root read-only initial: empty-node }
    { count fixnum read-only } ;

M: persistent-hash assoc-size count>> ;

M: persistent-hash at*
     [ dup hashcode >fixnum ] [ root>> ] bi* (entry-at)
     dup [ value>> t ] [ f ] if ;

M: persistent-hash new-at
    [
        [ 0 ] 3dip
        [ dup hashcode >fixnum ] [ root>> ] bi* (new-at) 1 0 ?
    ] [ count>> ] bi + persistent-hash boa ;

M: persistent-hash pluck-at
    [ [ dup hashcode >fixnum ] [ root>> ] bi* (pluck-at) ] keep
    {
        { [ 2dup root>> eq? ] [ nip ] }
        { [ over not ] [ 2drop T{ persistent-hash } ] }
        [ count>> 1 - persistent-hash boa ]
    } cond ;

M: persistent-hash >alist [ root>> >alist% ] { } make ;

M: persistent-hash keys >alist keys ;

M: persistent-hash values >alist values ;

: >persistent-hash ( assoc -- phash )
    T{ persistent-hash } swap [ swap rot new-at ] assoc-each ;

M: persistent-hash equal?
    over persistent-hash? [ assoc= ] [ 2drop f ] if ;

M: persistent-hash hashcode* nip assoc-size ;

M: persistent-hash clone ;

SYNTAX: PH{ \ } [ >persistent-hash ] parse-literal ;

M: persistent-hash pprint-delims drop \ PH{ \ } ;
M: persistent-hash >pprint-sequence >alist ;
M: persistent-hash pprint* pprint-object ;

: passociate ( value key -- phash )
    T{ persistent-hash } new-at ; inline

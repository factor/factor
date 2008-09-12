! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: math arrays kernel sequences
accessors locals persistent.hashtables.config ;
IN: persistent.hashtables.nodes

SINGLETON: empty-node

TUPLE: leaf-node
{ value read-only }
{ key read-only }
{ hashcode fixnum read-only } ;

C: <leaf-node> leaf-node

TUPLE: collision-node
{ hashcode fixnum read-only }
{ leaves array read-only } ;

C: <collision-node> collision-node

TUPLE: full-node
{ nodes array read-only }
{ shift fixnum read-only }
{ hashcode fixnum read-only } ;

: <full-node> ( nodes shift -- node )
    over first hashcode>> full-node boa ;

TUPLE: bitmap-node
{ bitmap fixnum read-only }
{ nodes array read-only }
{ shift fixnum read-only }
{ hashcode fixnum read-only } ;

: <bitmap-node> ( bitmap nodes shift -- node )
    pick full-bitmap-mask =
    [ <full-node> nip ]
    [ over first hashcode>> bitmap-node boa ] if ;

GENERIC: (entry-at) ( key hashcode node -- entry )

GENERIC: (new-at) ( shift value key hashcode node -- node' added-leaf )

GENERIC: (pluck-at) ( key hashcode node -- node' )

GENERIC: >alist% ( node -- )

: >alist-each% ( nodes -- ) [ >alist% ] each ;

: mask ( hash shift -- n ) neg shift radix-mask bitand ; inline

: bitpos ( hash shift -- n ) mask 2^ ; inline

: smash ( idx seq -- seq/elt ? )
    dup length 2 = [ [ 1 = ] dip first2 ? f ] [ remove-nth t ] if ; inline

:: make-bitmap-node ( shift branch value key hashcode -- node' added-leaf )
    shift value key hashcode
    branch hashcode>> shift bitpos
    branch 1array
    shift
    <bitmap-node>
    (new-at) ; inline

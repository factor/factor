! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: accessors kernel persistent.hashtables.nodes
persistent.hashtables.nodes.leaf persistent.sequences sequences ;
IN: persistent.hashtables.nodes.collision

: find-index ( key hashcode collision-node -- n leaf-node )
    leaves>> -rot '[ [ _ _ ] dip matching-key? ] find ; inline

M:: collision-node (entry-at) ( key hashcode collision-node -- leaf-node )
    key hashcode collision-node find-index nip ;

M:: collision-node (pluck-at) ( key hashcode collision-node -- leaf-node )
    hashcode collision-node hashcode>> eq? [
        key hashcode collision-node find-index drop :> idx
        idx [
            idx collision-node leaves>> smash [
                collision-node hashcode>>
                <collision-node>
            ] when
        ] [ collision-node ] if
    ] [ collision-node ] if ;

M:: collision-node (new-at) ( shift value key hashcode collision-node -- node' added-leaf )
    hashcode collision-node hashcode>> eq? [
        key hashcode collision-node find-index :> ( idx leaf-node )
        idx [
            value leaf-node value>> = [
                collision-node f
            ] [
                hashcode
                value key hashcode <leaf-node>
                idx
                collision-node leaves>>
                new-nth
                <collision-node>
                f
            ] if
        ] [
            value key hashcode <leaf-node> :> new-leaf-node
            hashcode
            collision-node leaves>>
            new-leaf-node
            suffix
            <collision-node>
            new-leaf-node
        ] if
    ] [
        shift collision-node value key hashcode make-bitmap-node
    ] if ;

M: collision-node >alist% leaves>> >alist-each% ;

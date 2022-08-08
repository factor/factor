! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: accessors arrays kernel make persistent.hashtables.nodes ;
IN: persistent.hashtables.nodes.leaf

: matching-key? ( key hashcode leaf-node -- ? )
    [ nip ] [ hashcode>> eq? ] 2bi
    [ key>> = ] [ 2drop f ] if ; inline

M: leaf-node (entry-at) [ matching-key? ] keep and ;

M: leaf-node (pluck-at) [ matching-key? not ] keep and ;

M:: leaf-node (new-at) ( shift value key hashcode leaf-node -- node' added-leaf )
    hashcode leaf-node hashcode>> eq? [
        key leaf-node key>> = [
            value leaf-node value>> =
            [ leaf-node f ] [ value key hashcode <leaf-node> f ] if
        ] [
            value key hashcode <leaf-node> :> new-leaf
            hashcode leaf-node new-leaf 2array <collision-node>
            new-leaf
        ] if
    ] [ shift leaf-node value key hashcode make-bitmap-node ] if ;

M: leaf-node >alist% [ key>> ] [ value>> ] bi 2array , ;

! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: accessors kernel persistent.hashtables.nodes ;
IN: persistent.hashtables.nodes.empty

M: empty-node (entry-at) 3drop f ;

M: empty-node (pluck-at) 2nip ;

M:: empty-node (new-at) ( shift value key hashcode node -- node' added-leaf )
    value key hashcode <leaf-node> dup ;

M: empty-node >alist% drop ;

M: empty-node hashcode>> drop 0 ;

USING: assocs kernel math namespaces sequences ;
IN: set-n
: get* ( var n -- val ) namestack swap tail-slice* assoc-stack ;

: set* ( val var n -- ) 1 + namestack [ length swap - ] keep nth set-at ;
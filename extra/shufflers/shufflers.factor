USING: kernel sequences words math math.functions arrays 
shuffle quotations parser math.parser strings namespaces 
splitting effects sequences.lib ;
IN: shufflers

: shuffle>string ( names shuffle -- string )
    swap [ [ nth ] curry map ] curry map
    first2 "-" swap 3append >string ;

: make-shuffles ( max-out max-in -- shuffles )
    [ 1+ dup rot strings [ 2array ] curry* map ]
    curry* map concat ;

: shuffle>quot ( shuffle -- quot )
    [
        first2 2dup [ - ] curry* map
        reverse [ , \ npick , \ >r , ] each
        swap , \ ndrop , length [ \ r> , ] times
    ] [ ] make ;

: put-effect ( word -- )
    dup word-name "-" split1
    [ >array [ 1string ] map ] 2apply
    <effect> "declared-effect" set-word-prop ;

: in-shuffle ( -- ) in get ".shuffle" append set-in ;
: out-shuffle ( -- ) in get ".shuffle" ?tail drop set-in ;

: define-shuffles ( names max-out -- )
    in-shuffle over length make-shuffles [
        [ shuffle>string create-in ] keep
        shuffle>quot dupd define-compound put-effect
    ] curry* each out-shuffle ;

: SHUFFLE:
    scan scan string>number define-shuffles ; parsing

! Copyright (C) 2011 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors fry generic generic.parser generic.standard
kernel present quotations sequences slots words
graphviz
graphviz.attributes
;
IN: graphviz.notation

<<

<PRIVATE

! GENERIC#: =attr 1 ( graphviz-obj val -- graphviz-obj' )
! M: edge/node =attr
!   present over attributes>> attr<< ;
! M: sub/graph =attr
!   <graph-attributes> swap present >>attr add ;
! M: edge/node/graph-attributes =attr
!   present >>attr ;

: =attr-generic ( name -- generic )
    "=" prepend "graphviz.notation" 2dup lookup-word
    [ 2nip ] [
        create-word dup
        1 <standard-combination>
        ( graphviz-obj val -- graphviz-obj' )
        define-generic
    ] if* ;

: =attr-method ( class name -- method name )
    [ =attr-generic create-method-in ] keep ;

: sub/graph-=attr ( attr -- )
    [ graph subgraph ] dip [
        =attr-method
        setter-word 1quotation
        '[ <graph-attributes> swap present @ add ]
        define
    ] curry bi@ ;

: edge/node-=attr ( class attr -- )
    =attr-method
    writer-word 1quotation '[ present over attributes>> @ ]
    define ;

: graph-obj-=attr ( class attr -- )
    over graph =
    [ nip sub/graph-=attr ]
    [ edge/node-=attr ] if ;

: attrs-obj-=attr ( class attr -- )
    =attr-method
    setter-word 1quotation '[ present @ ]
    define ;

: define-=attrs ( base-class attrs-class -- )
    dup "slots" word-prop [
        name>>
        [ attrs-obj-=attr ] keep
        graph-obj-=attr
    ] 2with each ;

PRIVATE>

graph graph-attributes define-=attrs
edge edge-attributes define-=attrs
node node-attributes define-=attrs

>>

ALIAS: -> add-edge
ALIAS: -- add-edge
ALIAS: ~-> add-path
ALIAS: ~-- add-path

ALIAS: [graph <graph-attributes>
ALIAS: [node <node-attributes>
ALIAS: [edge <edge-attributes>

ALIAS: [add-node <node>
ALIAS: [add-edge <edge>
ALIAS: [-> <edge>
ALIAS: [-- <edge>

ALIAS: ]; add

! Can't really do add-path[ & add-nodes[ this way, since they
! involve multiple objects.

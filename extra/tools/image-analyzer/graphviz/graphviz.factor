USING: accessors alien.strings assocs classes fry graphviz
graphviz.attributes graphviz.notation kernel sequences system
tools.image-analyzer.references tools.image-analyzer.vm vocabs.parser ;
IN: tools.image-analyzer.graphviz
FROM: arrays => 1array 2array ;
FROM: byte-arrays => >byte-array ;
FROM: kernel => object ;
FROM: math => <= - shift ;

<<
! For the two annoying structs that differ on 32 and 64 bit.
cpu x86.32?
"tools.image-analyzer.vm.32"
"tools.image-analyzer.vm.64"
? use-vocab
>>

: array>string ( array -- str )
    0 suffix >byte-array alien>native-string ;

CONSTANT: node-colors {
    { array "#999999" }
    { bignum "#cc3311" }
    { byte-array "#ffff00" }
    { code-block "#ffaaff" }
    { string "#aaddff" }
    { quotation "#449900" }
    { word "#00ffcc" }
}

: heap-node>color ( heap-node -- color )
    object>> class-of node-colors at ;

: relativise-address ( image heap-node -- address )
    swap [
        [ address>> ] [ code-heap-node? ] bi
    ] [
        header>> [ code-relocation-base>> ] [ data-relocation-base>> ] bi
    ] bi* ? - ;

: heap-node>label ( image heap-node -- label )
    dup object>> string? [
        nip payload>> array>string
    ] [ relativise-address ] if ;

: heap-node>node ( image heap-node -- node )
    [ heap-node>label ] [ heap-node>color ] [ address>> ] tri
    <node> swap =fillcolor swap =label "filled" =style ;

: add-nodes ( graph image -- graph )
    dup heap>> [ heap-node>node add ] with each ;

: heap-node-edges ( heap heap-node -- seq )
    [ collect-pointers ] keep address>> '[ _ swap 2array ] map ;

: image>edges ( image -- edges )
    heap>> dup [ heap-node-edges ] with map concat ;

: add-graphviz-edges ( graph edges -- graph )
    [ first2 add-edge ] each ;

: add-edges ( graph image -- graph )
    image>edges add-graphviz-edges ;

: <heap-graph> ( -- graph )
    <digraph>
    [graph "neato" =layout ];
    <graph-attributes> "false" >>overlap add ;

: image>graph ( image -- graph )
    <heap-graph> over add-nodes swap add-edges ;

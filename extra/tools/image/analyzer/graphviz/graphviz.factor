! Copyright (C) 2015 - 2016 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license
USING: accessors alien.strings assocs classes fry graphviz
graphviz.attributes graphviz.notation math.bitwise sequences sets
system tools.image.analyzer.references tools.image.analyzer.utils
tools.image.analyzer.vm vocabs.parser ;
IN: tools.image.analyzer.graphviz
FROM: arrays => 1array 2array ;
FROM: byte-arrays => >byte-array ;
FROM: kernel => ? = 2drop bi bi* dup if keep nip object over swap tri with ;
FROM: math => <= - shift ;

<<
! For the two annoying structs that differ on 32 and 64 bit.
cpu x86.32?
"tools.image.analyzer.vm.32"
"tools.image.analyzer.vm.64"
? use-vocab
>>

: array>string ( array -- str )
    0 suffix >byte-array alien>native-string ;

! Regular nodes
CONSTANT: node-colors {
    { alien "#aa5566" }
    { array "#999999" }
    { bignum "#cc3311" }
    { byte-array "#ffff00" }
    { code-block "#ffaaff" }
    { string "#aaddff" }
    { tuple "#abcdef" }
    { quotation "#449900" }
    { word "#00ffcc" }
    { wrapper "#ffaa77" }
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

: add-heap-nodes ( graph image -- graph )
    dup heap>> [ heap-node>node add ] with each ;

! Root nodes
: <root-node> ( id -- node )
    <node> "box" =shape ;

: add-root-node ( graph ptr index -- graph )
    over 15 mask 1 <= [ 2drop ] [
        [ swap untag add-edge ] keep <root-node> add
    ] if ;

: add-root-nodes ( graph image -- graph )
    0 <cluster> swap
    header>> special-objects>> [ add-root-node ] each-index
    add ;

! Edges
: heap-node-edges ( heap heap-node -- seq )
    [ collect-pointers ] keep address>> '[ _ swap 2array ] map ;

: image>edges ( image -- edges )
    heap>> dup [ heap-node-edges ] with map concat
    members [ first2 = ] reject ;

: add-graphviz-edges ( graph edges -- graph )
    [ first2 add-edge ] each ;

: add-edges ( graph image -- graph )
    image>edges add-graphviz-edges ;

: <heap-graph> ( -- graph )
    <digraph>
    [graph "dot" =layout ];
    <graph-attributes> "false" >>overlap add ;

: image>graph ( image -- graph )
    <heap-graph> over add-heap-nodes over add-root-nodes swap add-edges ;

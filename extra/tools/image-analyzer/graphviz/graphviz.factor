USING: accessors alien.strings assocs classes graphviz
graphviz.attributes graphviz.notation kernel math.parser sequences
slots.syntax system tools.image-analyzer
tools.image-analyzer.ref-fixer tools.image-analyzer.vm vocabs.parser ;
IN: tools.image-analyzer.graphviz
FROM: arrays => 1array 2array ;
FROM: byte-arrays => >byte-array ;
FROM: kernel => object ;
FROM: math => - ;

<<
! For the two annoying structs that differ on 32 and 64 bit.
cpu x86.32?
"tools.image-analyzer.vm.32"
"tools.image-analyzer.vm.64"
? use-vocab
>>

GENERIC: object-references ( struct -- seq )

M: word object-references ( struct -- seq )
    slots{ def entry_point name props vocabulary } ;

M: code-block object-references ( struct -- seq )
    slots{ owner parameters relocation } ;

M: object object-references ( struct -- seq )
    drop { } ;

: heap-node>edges ( heap-node -- edges )
    [ address>> ]
    [
        object>> object-references [ 1 = ] reject
    ] bi [ 2array ] with map ;

CONSTANT: node-colors {
    { array "#999999" }
    { bignum "#cc3311" }
    { byte-array "#ffff00" }
    { code-block "#ffaaff" }
    { string "#aaddff" }
    { quotation "#449900" }
    { word "#00ff99" }
}

: array>string ( array -- str )
    0 suffix >byte-array alien>native-string ;

: heap-node>label ( heap-node -- id )
    dup object>> dup string? [ drop payload>> array>string ] [
        [ address>> ] dip
        code-block? [ code-heap-shift - ] when number>string
    ] if ;

: heap-node>fill-color ( heap-node -- color )
    object>> class-of node-colors at ;

: heap-node>node ( heap-node -- node )
    dup address>> <node>
    over heap-node>fill-color =fillcolor
    swap heap-node>label =label
    "filled" =style ;

: add-edges ( graph edges -- graph )
    [ first2 add-edge ] each ;

: setup-graph ( graph -- graph )
    [graph "neato" =layout ];
    <graph-attributes> "false" >>overlap add ;

: make-graph ( heap-nodes -- graph )
    dup <digraph> setup-graph
    swap [ heap-node>node add ] each
    swap [ heap-node>edges add-edges ] each ;

: graph-image ( image -- graph )
    load-image swap dupd fix-references make-graph ;
